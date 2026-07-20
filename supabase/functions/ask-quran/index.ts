// supabase/functions/ask-quran/index.ts
//
// Bu Edge Function, Supabase CLI ile deploy edilir:
//   supabase functions deploy ask-quran
//
// Gerekli ortam değişkenleri (Supabase Dashboard > Edge Functions >
// ask-quran > Secrets bölümünden eklenir):
//   GEMINI_API_KEY       -> embedding üretmek için, ÜCRETSİZ
//                           (aistudio.google.com'dan alınır, kredi kartı gerekmez)
//   OPENAI_API_KEY       -> cevap üretmek için (chat completion)
//
// Akış:
// 1. Kullanıcının sorusunu Google Gemini'nin ÜCRETSİZ embedding API'siyle
//    vektöre çevir (gemini-embedding-001, 768 boyut) — quran_verves
//    tablosundaki embedding'lerle AYNI model olması ZORUNLU.
// 2. Bu vektöre en yakın ayetleri `match_quran_verses` fonksiyonuyla bul
// 3. Bulunan ayetleri "bağlam" olarak OpenAI'ye ver, SADECE bu ayetlere
//    dayanarak cevap üretmesini iste (sistem promptu bunu zorunlu kılar)
// 4. Cevabı Flutter'a JSON olarak döndür

import { createClient } from 'jsr:@supabase/supabase-js@2';

const SYSTEM_PROMPT = `Sen "Hardal Tanesi" uygulamasının "Kur'an'a Sor" \
asistanısın. Kullanıcının sorusuna SADECE sana verilen Kur'an ayetlerine \
dayanarak cevap ver. Hadis, sünnet, mezhep görüşü ya da kendi yorumunu \
KESİNLİKLE ekleme — sadece verilen ayetleri kullan. Her cevabında ilgili \
ayet(ler)i tam olarak şu formatta, tırnak içinde göster:

"[ayetin Türkçe meali]"
[Sure Adı] Suresi, [numara]. Ayet

Cevabın kısa, sakin ve şefkatli bir üslupla olsun — vaaz verir gibi değil, \
bir dost gibi konuş. Eğer verilen ayetler arasında soruyla doğrudan \
ilgili bir şey yoksa, bunu dürüstçe belirt ve en yakın anlamlı ayeti \
paylaş.`;

interface RequestBody {
  message: string;
  history: Array<{ sender: 'user' | 'ai'; text: string }>;
}

/// Google Gemini'nin ücretsiz embedding API'sini çağırır.
/// NOT: quran_verses tablosundaki embedding'ler de bu AYNI modelle
/// (gemini-embedding-001, 768 boyut) üretildi — burası değişirse
/// vektör karşılaştırması anlamsız hale gelir.
async function embedText(text: string, geminiKey: string): Promise<number[]> {
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=${geminiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        content: { parts: [{ text }] },
        outputDimensionality: 768,
      }),
    },
  );
  const data = await response.json();
  if (!data.embedding?.values) {
    throw new Error(`Gemini embedding hatası: ${JSON.stringify(data)}`);
  }
  return data.embedding.values;
}

Deno.serve(async (req: Request) => {
  try {
    const { message, history }: RequestBody = await req.json();

    if (!message || message.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: 'message boş olamaz' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      );
    }

    const geminiKey = Deno.env.get('GEMINI_API_KEY');
    const openaiKey = Deno.env.get('OPENAI_API_KEY');
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    if (!geminiKey || !openaiKey) {
      throw new Error(
        'GEMINI_API_KEY ve OPENAI_API_KEY secret olarak eklenmeli.',
      );
    }

    // service_role ile bağlan — RLS'i bypass eder, sadece sunucu
    // tarafında çalıştığı için güvenli.
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // 1. Kullanıcının sorusunu embedding'e çevir (ücretsiz Gemini API).
    const queryEmbedding = await embedText(message, geminiKey);

    // 2. En yakın ayetleri bul.
    const { data: verses, error: matchError } = await supabase.rpc(
      'match_quran_verses',
      { query_embedding: queryEmbedding, match_count: 5 },
    );
    if (matchError) throw matchError;

    const context = (verses ?? [])
      .map(
        (v: { surah_name: string; ayah_number: number; turkish_text: string }) =>
          `"${v.turkish_text}" — ${v.surah_name} Suresi, ${v.ayah_number}. Ayet`,
      )
      .join('\n\n');

    // 3. OpenAI'ye bağlam + soruyu gönder.
    const recentHistory = (history ?? [])
      .slice(-6)
      .map((m) => ({
        role: m.sender === 'user' ? 'user' : 'assistant',
        content: m.text,
      }));

    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: `${SYSTEM_PROMPT}\n\nİlgili ayetler:\n${context}`,
          },
          ...recentHistory,
          { role: 'user', content: message },
        ],
        temperature: 0.4,
        max_tokens: 700,
      }),
    });

    if (!openaiResponse.ok) {
      const errText = await openaiResponse.text();
      console.error('OpenAI API hatası:', errText);
      throw new Error('Cevap oluşturulamadı');
    }

    const openaiData = await openaiResponse.json();
    const answerText = openaiData.choices?.[0]?.message?.content ??
      'Şu an bir cevap üretemedim, lütfen tekrar dene.';

    return new Response(
      JSON.stringify({ text: answerText }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    console.error('ask-quran hatası:', error);
    return new Response(
      JSON.stringify({ error: 'Sunucu hatası' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});