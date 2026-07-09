-- pgvector eklentisini aktif et (Supabase'de genelde zaten kurulu,
-- yine de garanti olsun diye).
create extension if not exists vector;

-- Kur'an'ın her ayetini ve embedding'ini (anlamsal vektörünü) tutan tablo.
-- NOT: Bu tablo şimdilik BOŞ oluşuyor — 6236 ayetin embedding'lerini
-- doldurmak ayrı bir script ile yapılacak (bkz. sonraki adım).
--
-- Embedding modeli: Google Gemini (gemini-embedding-001), ÜCRETSİZ katman
-- (Google AI Studio üzerinden, kredi kartı gerektirmiyor). 768 boyut
-- kullanıyoruz — Google'ın "yüksek kalite için önerilen" en küçük
-- seçeneği, hem depolama hem hız açısından avantajlı.
create table if not exists public.quran_verses (
  id uuid primary key default gen_random_uuid(),
  surah_number int not null,
  surah_name text not null,
  ayah_number int not null,
  arabic_text text,
  turkish_text text not null,
  embedding vector(768),
  created_at timestamptz not null default now()
);

alter table public.quran_verses enable row level security;

-- Bu tabloyu sadece Edge Function (service_role ile) okuyacak, anon key
-- ile doğrudan erişim gerekmiyor — bu yüzden herkese açık bir SELECT
-- policy YAZMIYORUZ. Edge Function service_role kullandığı için RLS'i
-- zaten bypass eder.

-- Anlamsal benzerlik araması için fonksiyon: verilen embedding'e en
-- yakın N ayeti döner (cosine similarity).
create or replace function public.match_quran_verses(
  query_embedding vector(768),
  match_count int default 5
)
returns table (
  surah_name text,
  ayah_number int,
  turkish_text text,
  similarity float
)
language sql
stable
as $$
  select
    surah_name,
    ayah_number,
    turkish_text,
    1 - (embedding <=> query_embedding) as similarity
  from public.quran_verses
  order by embedding <=> query_embedding
  limit match_count;
$$;

-- Vektör aramasını hızlandıran index (veri dolunca performans için
-- önemli, tablo boşken de çalıştırılabilir).
create index if not exists quran_verses_embedding_idx
  on public.quran_verses
  using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);