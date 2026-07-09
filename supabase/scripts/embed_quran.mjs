// supabase/scripts/embed_quran.mjs
//
// Kur'an'ın tamamını (6236 ayet) Türkçe mealiyle birlikte çekip, HER
// AYETİ Google Gemini'nin ÜCRETSİZ embedding API'siyle vektöre çevirip
// Supabase'deki `quran_verses` tablosuna yazar.
//
// GÜNLÜK KOTA: Gemini'nin ücretsiz katmanı günde ~1000 embedding isteğine
// izin veriyor. Bu yüzden script, halihazırda yüklenmiş ayetleri ATLAYIP
// kaldığı yerden devam edecek şekilde tasarlandı — birkaç gün üst üste
// çalıştırman yeterli (6236 / 1000 ≈ 7 gün).
//
// KULLANIM: Her gün aynı komutu tekrar çalıştır:
//   node embed_quran.mjs
// Günlük kotaya ulaşınca script kendiliğinden düzgünce duracak, ertesi
// gün tekrar çalıştırdığında kaldığı yerden devam edecek.

import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

// ---- Key'ler artık .env dosyasından okunuyor (Git'e gitmiyor) ----
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const SUPABASE_URL = 'https://smdtadmonbyxrklhiyxf.supabase.co';
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!GEMINI_API_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error(
    'HATA: .env dosyası eksik ya da GEMINI_API_KEY / SUPABASE_SERVICE_ROLE_KEY tanımlı değil.',
  );
  process.exit(1);
}
// --------------------------------------------------------------

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const QURAN_API = 'https://api.alquran.cloud/v1/quran/tr.diyanet';

async function fetchQuran() {
  console.log("Kur'an verisi çekiliyor (Al-Quran Cloud API)...");
  const response = await fetch(QURAN_API);
  const json = await response.json();
  return json.data.surahs;
}

/// Zaten yüklenmiş (surah_number, ayah_number) çiftlerini çekip bir Set
/// olarak döner — böylece script hangi ayetlerin daha önce işlendiğini
/// bilip onları atlayabiliyor.
async function fetchAlreadyLoaded() {
  console.log('Daha önce yüklenmiş ayetler kontrol ediliyor...');
  const loaded = new Set();
  let from = 0;
  const pageSize = 1000;

  while (true) {
    const { data, error } = await supabase
      .from('quran_verses')
      .select('surah_number, ayah_number')
      .range(from, from + pageSize - 1);

    if (error) throw error;
    if (!data || data.length === 0) break;

    for (const row of data) {
      loaded.add(`${row.surah_number}:${row.ayah_number}`);
    }

    if (data.length < pageSize) break;
    from += pageSize;
  }

  console.log(`${loaded.size} ayet zaten yüklenmiş, bunlar atlanacak.`);
  return loaded;
}

async function embedText(text) {
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=${GEMINI_API_KEY}`,
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

  if (data.error?.status === 'RESOURCE_EXHAUSTED') {
    const isDailyQuota = JSON.stringify(data.error).includes('PerDay');
    throw new DailyQuotaError(isDailyQuota);
  }
  if (!data.embedding?.values) {
    throw new Error(`Gemini embedding hatası: ${JSON.stringify(data)}`);
  }
  return data.embedding.values;
}

class DailyQuotaError extends Error {
  constructor(isDailyQuota) {
    super('Günlük kota doldu');
    this.isDailyQuota = isDailyQuota;
  }
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const [surahs, alreadyLoaded] = await Promise.all([
    fetchQuran(),
    fetchAlreadyLoaded(),
  ]);

  let totalVerses = 0;
  for (const surah of surahs) totalVerses += surah.ayahs.length;

  const remaining = totalVerses - alreadyLoaded.size;
  console.log(
    `Toplam ${totalVerses} ayet, ${remaining} tanesi bugün işlenecek.`,
  );

  let processedToday = 0;

  for (const surah of surahs) {
    for (const ayah of surah.ayahs) {
      const key = `${surah.number}:${ayah.numberInSurah}`;
      if (alreadyLoaded.has(key)) continue; // Zaten yüklenmiş, atla.

      try {
        const embedding = await embedText(ayah.text);

        const { error } = await supabase.from('quran_verses').insert({
          surah_number: surah.number,
          surah_name: surah.name,
          ayah_number: ayah.numberInSurah,
          turkish_text: ayah.text,
          embedding,
        });

        if (error) {
          console.error(`HATA (${surah.name} ${ayah.numberInSurah}):`, error.message);
        } else {
          processedToday++;
          if (processedToday % 50 === 0) {
            console.log(`Bugünkü ilerleme: ${processedToday}/${remaining}`);
          }
        }

        await sleep(1200); // Dakikalık istek sınırına takılmamak için.
      } catch (err) {
        if (err instanceof DailyQuotaError) {
          console.log('\n=================================================');
          console.log(`Günlük kota doldu. Bugün ${processedToday} ayet yüklendi.`);
          console.log('Yarın aynı komutu tekrar çalıştır, kaldığı yerden devam edecek:');
          console.log('  node embed_quran.mjs');
          console.log('=================================================\n');
          process.exit(0);
        }
        console.error(`Beklenmeyen hata (${surah.name} ${ayah.numberInSurah}):`, err.message);
        await sleep(5000);
      }
    }
  }

  console.log(`\nTAMAMLANDI! Kur'an'ın tamamı (${totalVerses} ayet) yüklendi.`);
}

main().catch((err) => {
  console.error('Script başarısız oldu:', err);
  process.exit(1);
});
