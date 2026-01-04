# Instagram Analytics dbt Project

## Ringkasan
Proyek dbt ini mengimplementasikan model data **Instagram Analytics** untuk menghitung metrik unengagement konten. Proyek ini mengikuti arsitektur tiga lapisan: **staging → intermediate → mart**.

## Struktur Proyek
```
instagram_analytics/
├── models/
│   ├── staging/
│   │   └── instagram/
│   │       ├── stg_instagram__media_history.sql
│   │       ├── stg_instagram__media_insights.sql
│   │       └── stg_instagram__schema.yml
│   ├── intermediate/
│   │   └── instagram/
│   │       ├── int_instagram__media_engagement.sql
│   │       └── int_instagram__schema.yml
│   └── mart/
│       └── instagram/
│           ├── current_content_unengagement.sql
│           └── mart_instagram__schema.yml
├── seeds/
│   └── raw_data/
│       ├── media_history.csv
│       ├── media_insights.csv
│       └── seeds.yml
├── dbt_project.yml
└── README.md
```

## Metrik: `current_content_unengagement`

### Deskripsi
Menghitung jumlah tindakan unlike, unsave, uncomment dan unshare per postingan Instagram.

### Kolom yang Diperlukan
- `id`: Unique identifier konten yang telah dipublikasi
- `created_time`: Waktu publikasi konten dalam WIB (UTC+7)
- `user_id`: Unique identifier username Instagram
- `media_type`: Tipe media yang diunggah di Instagram (VIDEO, IMAGE, CAROUSEL_ALBUM)
- `media_product_type`: Kategorisasi media_type dalam produk Instagram (REELS, FEED, STORY)
- `unengagements`: Jumlah unlike, unsave, uncomment dan unshares

## Arsitektur Model Data

### 1. Lapisan Staging
**Tujuan:** Membersihkan dan menstandarisasi data mentah

- **`stg_instagram__media_history`**: Transformasi data riwayat media mentah
  - Mengonversi timestamp dari UTC ke WIB (UTC+7)
  - Menstandarisasi nama dan tipe kolom
  
- **`stg_instagram__media_insights`**: Transformasi data insights media mentah
  - Mengonversi metrik engagement ke tipe integer
  - Menangani nilai NULL dengan tepat

### 2. Lapisan Intermediate
**Tujuan:** Logika bisnis dan transformasi

- **`int_instagram__media_engagement`**: Menggabungkan riwayat media dengan metrik engagement saat ini dan sebelumnya
  - Menggabungkan riwayat media dengan insights terbaru
  - Menghitung perubahan metrik engagement dari waktu ke waktu
  - Mempersiapkan data untuk perhitungan unengagement

### 3. Lapisan Mart
**Tujuan:** Model akhir yang siap untuk analitik

- **`current_content_unengagement`**: Perhitungan metrik akhir
  - Menghitung unengagement berdasarkan tipe media
  - Menangani pola engagement yang berbeda untuk konten REELS, FEED, dan STORY
  - Menerapkan aturan bisnis untuk setiap tipe konten

## Instalasi & Pengaturan

### Prasyarat
- Python 3.8+
- dbt-core
- dbt-duckdb

### Langkah-langkah Setup

1. **Clone repository**
```bash
git clone <your-repo-url>
cd instagram_analytics
```

2. **Install dependensi**
```bash
pip install dbt-core dbt-duckdb
```

3. **Load data seed**
```bash
dbt seed
```

4. **Jalankan model**
```bash
dbt run
```

5. **Test model**
```bash
dbt test
```

6. **Generate dokumentasi**
```bash
dbt docs generate
dbt docs serve
```

## Contoh Penggunaan

### Query metrik akhir
```sql
SELECT 
    id,
    created_time,
    user_id,
    media_type,
    media_product_type,
    unengagements
FROM current_content_unengagement
WHERE unengagements > 0
ORDER BY created_time DESC
LIMIT 10;
```

### Analisis unengagement berdasarkan tipe media
```sql
SELECT 
    media_type,
    media_product_type,
    COUNT(*) as content_count,
    SUM(unengagements) as total_unengagements,
    AVG(unengagements) as avg_unengagements
FROM current_content_unengagement
GROUP BY media_type, media_product_type
ORDER BY total_unengagements DESC;
```

## Tes Kualitas Data

Proyek ini mencakup tes kualitas data berikut:
- Pemeriksaan not null pada field kritis (id, created_time, user_id, unengagements)
- Validasi tipe data
- Validasi logika bisnis

Jalankan tes dengan:
```bash
dbt test
```

## Konfigurasi

### profiles.yml
```yaml
instagram_analytics:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: instagram_analytics.duckdb
      threads: 4
```

### dbt_project.yml
- Staging models: `materialized: view`
- Intermediate models: `materialized: view`
- Mart models: `materialized: table`

## Panduan Pengembangan

1. **Model Staging**: Hanya pembersihan dan type casting, tidak ada logika bisnis
2. **Model Intermediate**: Operasi join dan transformasi kompleks
3. **Model Mart**: Metrik bisnis akhir, dioptimalkan untuk query
4. **Konvensi Penamaan**: 
   - Staging: `stg_<source>__<entity>`
   - Intermediate: `int_<source>__<entity>`
   - Mart: `<metric_name>`

