# GridInspect – Panduan Penerapan Design System (Stitch → Kode)

Dokumen ini menjelaskan cara menerapkan desain dari Stitch ke kode aplikasi **Inspeksi Lapangan** (3 halaman: Monitoring, Peta, Form Inspeksi Detail). Sumber: gambar design system + 3 file HTML hasil ekspor Stitch.

> **Aturan emas:** jangan menulis warna / font / ukuran secara manual (mis. `#0284C7`, `text-[15px]`). Selalu pakai **token** di bawah ini.

---

## 1. Warna

### 1.1 Palet utama (dari design system)

| Peran     | Hex       | Pemakaian                                                       |
|-----------|-----------|-----------------------------------------------------------------|
| Primary   | `#0F172A` | Tombol utama, teks judul, tab aktif, header gelap               |
| Secondary | `#0284C7` | Aksi, link, ikon aktif, status "Selesai", GPS/sinkron           |
| Tertiary  | `#F59E0B` | Status "Pending / Belum Dikerjakan", peringatan, penanda target |
| Neutral   | `#64748B` | Teks sekunder, label, ikon non-aktif                            |
| Error     | `#DC2626` (merah tombol hapus) | Hapus, field wajib `*`, error      |

Setiap warna memiliki **ramp 10 tingkat** (gelap → terang). Jadikan skala 900 → 50.

### 1.2 Catatan penting: token di kode Stitch ≠ hex di gambar

File HTML hasil ekspor memakai token bergaya Material (mis. `secondary: #006398`, `on-tertiary-container: #b87500`, `primary: #000000`), sedangkan gambar design system menunjukkan hex `#0F172A / #0284C7 / #F59E0B / #64748B`. Pilih **satu sumber kebenaran**:

- **Opsi A (disarankan, setia ke gambar):** pakai hex dari gambar sebagai nilai token (lihat §7).
- **Opsi B (cepat, tanpa ubah apa pun):** biarkan `tailwind.config` bawaan Stitch.

Jangan mencampur keduanya di satu proyek.

### 1.3 Token semantik (nama dipertahankan agar kelas Tailwind di HTML tidak perlu diubah)

| Token                      | Fungsi                                   |
|----------------------------|------------------------------------------|
| `surface`, `background`    | Latar halaman                            |
| `surface-container-lowest` | Kartu putih                              |
| `surface-container-low`    | Blok di dalam kartu                      |
| `surface-container`        | Chip, tombol sekunder, latar ikon        |
| `surface-container-high`   | Badge info, tombol sekunder aktif        |
| `on-surface`               | Teks utama                               |
| `on-surface-variant`       | Teks sekunder                            |
| `outline-variant`          | Pemisah halus                            |
| `secondary`                | Aksi & status berhasil                   |
| `on-tertiary-container`    | Teks/ikon status pending                 |
| `tertiary-fixed-dim`       | Titik/penanda pending                    |
| `error` / `error-container`| Error, "Wajib Kamera"                    |

---

## 2. Tipografi

| Peran    | Font           | Dipakai untuk                                  |
|----------|----------------|------------------------------------------------|
| Headline | Space Grotesk  | Judul, angka statistik, ID, data teknis        |
| Body     | Chivo          | Paragraf, deskripsi, input                     |
| Label    | Chivo (bold)   | Label field, chip, badge, tombol               |

Skala (sudah ada di config, gunakan lewat kelas `text-*`):

| Kelas                | Ukuran / Line-height | Berat |
|----------------------|----------------------|-------|
| `text-headline-xl`   | 32 / 40              | 700   |
| `text-headline-xl-mobile` | 26 / 32         | 700   |
| `text-headline-lg`   | 24 / 32              | 700   |
| `text-headline-md`   | 20 / 28              | 600   |
| `text-headline-sm`   | 18 / 24              | 600   |
| `text-body-lg`       | 16 / 24              | 500   |
| `text-body-md`       | 15 / 22              | 400   |
| `text-body-sm`       | 13 / 18              | 400   |
| `text-label-lg`      | 14 / 20              | 700   |
| `text-label-md`      | 12 / 16              | 700   |
| `text-label-sm`      | 11 / 14              | 700   |
| `text-code-data`     | 13 / 18              | 500   |

**Pasangan wajib** – selalu tulis family + size bersama:
```html
<span class="font-headline-sm text-headline-sm">Judul</span>
<span class="font-body-sm text-body-sm">Deskripsi</span>
<span class="font-code-data text-code-data">538201948210</span>
```
Aturan: **IDPEL, no. seri meter, koordinat, stand meter** → selalu `font-code-data`.

Load font:
```html
<link href="https://fonts.googleapis.com/css2?family=Chivo:wght@400;500;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
```
> Hapus link Material Symbols yang duplikat (di HTML Stitch dimuat dua kali); cukup satu.

---

## 3. Spacing, radius, bayangan

**Spacing** (nama custom Tailwind):

| Token        | Nilai    | Contoh                          |
|--------------|----------|---------------------------------|
| `space-xs`   | 0.25rem  | Jarak ikon–teks                 |
| `space-sm`   | 0.5rem   | Jarak antar elemen kecil        |
| `space-md`   | 0.75rem  | Padding kartu, gap list         |
| `margin`     | 1rem     | Margin halaman kiri/kanan       |
| `space-lg`   | 1.25rem  | Jarak antar seksi               |
| `space-xl`   | 2rem     | Jarak besar                     |

**Radius** (sudah dioverride):  `rounded-lg` = 4px (tombol/input), `rounded-xl` = 8px (kartu), `rounded-full` = 12px (chip/badge).
> Karena `rounded-full` dioverride menjadi 12px, gunakan `rounded-[9999px]` bila butuh lingkaran penuh (titik status, avatar).

**Bayangan:** `shadow-sm` untuk kartu, `shadow-md` untuk elemen melayang (sheet peta), `shadow-xl` untuk bottom sheet. **Tidak memakai border** – pemisahan lewat beda warna surface + shadow halus.

---

## 4. Komponen

### 4.1 Tombol (sesuai gambar: Primary / Secondary / Inverted / Outlined)

```html
<!-- Primary -->
<button class="h-12 px-4 rounded-lg bg-primary text-on-primary font-label-lg text-label-lg active:scale-[0.98] transition-transform">Primary</button>

<!-- Secondary (aksi utama berwarna biru) -->
<button class="h-12 px-4 rounded-lg bg-secondary text-on-secondary font-label-lg text-label-lg shadow-sm active:scale-[0.98] transition-transform">Buka Form Inspeksi</button>

<!-- Tonal / ghost -->
<button class="h-12 px-4 rounded-lg bg-surface-container text-secondary font-label-lg text-label-lg active:scale-95 transition-transform">Secondary</button>

<!-- Inverted (navy gelap, untuk CTA di peta) -->
<button class="h-12 px-4 rounded-lg bg-primary-container text-surface-bright font-label-lg text-label-lg shadow-md">Mulai Inspeksi</button>

<!-- Outlined -->
<button class="h-12 px-4 rounded-lg bg-surface-container-lowest text-on-surface ring-1 ring-outline-variant font-label-lg text-label-lg">Outlined</button>
```
Aturan: tinggi minimal **48px (`h-12`)**, target sentuh minimal **44px**. Efek tekan: `active:scale-[0.98]` / `active:scale-95`.

### 4.2 Tombol ikon (kotak 44×44)
- Netral: `w-11 h-11 rounded-lg bg-surface-container text-secondary`
- Gelap/aksen: `bg-primary text-on-primary`
- Edit (ikon pensil kuning di latar gelap): `bg-tertiary-container text-tertiary-fixed-dim`
- Hapus: `bg-error text-on-error`
- Info/segel: `bg-secondary text-on-secondary`

### 4.3 Input pencarian
```html
<div class="flex items-center gap-space-xs bg-surface-container-lowest rounded-xl p-1.5 shadow-sm">
  <span class="material-symbols-outlined pl-2 text-on-surface-variant">search</span>
  <input class="w-full bg-transparent font-body-md text-body-md focus:outline-none py-1.5" placeholder="Cari Nama, IDPEL, atau Alamat...">
</div>
```
Input form: `h-12 px-3 bg-surface-container-lowest rounded shadow-sm font-body-md focus:bg-surface-container-low focus:outline-none` (tanpa border).

### 4.4 Chip filter
- Aktif: `bg-primary text-on-primary`
- Tidak aktif: `bg-surface-container text-on-surface-variant`
- Bentuk: `px-3.5 py-1.5 rounded-full font-label-md text-label-md whitespace-nowrap`

### 4.5 Bottom navigation (3 tab)
Tab **aktif** = ikon + label `text-secondary` (di gambar: ikon putih di pill hitam – boleh dipakai sebagai varian pill: `bg-primary text-on-primary rounded-lg`). Tab non-aktif = `text-on-surface-variant`. Tinggi `h-20`, tambahkan `pb-safe`.

### 4.6 Status badge
| Status         | Kelas                                                                           |
|----------------|---------------------------------------------------------------------------------|
| Belum Dikerjakan | `bg-surface-container-high text-on-tertiary-container` + titik kuning          |
| Selesai          | `bg-surface-container text-secondary` + ikon `verified`                        |
| Tindak Lanjut    | `bg-error-container text-on-error-container`                                    |

### 4.7 Kartu pelanggan
Struktur: `bg-surface-container-lowest rounded-xl shadow-sm` → header (nama `font-headline-sm`, ID `font-code-data text-secondary`) → blok alamat `bg-surface-container-low rounded-lg` → baris aksi (`grid grid-cols-5`: 4 kolom tombol utama + 1 kolom tombol peta).

### 4.8 Bar / garis progres
Garis tebal 4px: hitam (`bg-primary`) untuk total, biru (`bg-secondary`) untuk progres, abu (`bg-outline-variant`) untuk sisa. Lebar progres = persen selesai.

---

## 5. Pola per halaman

| Halaman            | Shell        | Catatan                                                                 |
|--------------------|--------------|-------------------------------------------------------------------------|
| Monitoring         | `mobile_tab` | Header tetap + bottom nav; statistik 3 kolom; search + chip; daftar kartu |
| Peta               | `mobile_tab` | Peta penuh `h-[calc(100vh-8.5rem)]`; telemetri GPS di atas; bottom sheet |
| Form Inspeksi      | `mobile_stack` | Tanpa bottom nav; tombol kembali; **sticky action bar** di bawah       |

Pola umum:
- Header: `fixed top-0 h-16 bg-surface/80 backdrop-blur-xl pt-safe`
- Konten: `pt-16 pb-24` (ada bottom nav) atau `pb-32` (ada sticky action bar)
- Padding halaman: `px-margin`; jarak antar seksi: `gap-space-lg`

---

## 6. Menerapkan ke proyek – langkah demi langkah

1. **Pusatkan config.** Pindahkan blok `tailwind.config` yang diulang di tiap HTML ke **satu file** (`tailwind.config.js` bila pakai build, atau `theme.js` bila pakai CDN) dan import di semua halaman.
2. **Pindahkan CSS umum** (`.pb-safe`, `.pt-safe`, sembunyikan scrollbar) ke satu `base.css`.
3. **Ganti nilai token** sesuai Opsi A (§7) bila ingin setia pada gambar.
4. **Ekstrak komponen berulang**: `AppHeader`, `BottomNav`, `StatusBadge`, `CustomerCard`, `Chip`, `Button`, `FormField`, `StickyActionBar`. Jangan salin-tempel HTML kartu.
5. **Ganti data statis** (nama, ID, angka 24/14/10, koordinat) dengan data dari API/state; jadikan filter chip & hitungan dinamis (hitung dari data, bukan ditulis tangan).
6. **Hubungkan interaksi** yang saat ini masih simulasi (`setTimeout`): GPS asli (`navigator.geolocation`), kamera (`getUserMedia` / input `capture="environment"`, tanpa galeri), simpan offline (IndexedDB), sync.
7. **Uji** di lebar 360–430px, mode offline, dan perangkat dengan notch (safe-area).

---

## 7. Konfigurasi Tailwind (Opsi A – selaras gambar)

```js
// tailwind.config.js
module.exports = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: "#0F172A",
        "on-primary": "#FFFFFF",
        "primary-container": "#0F172A",

        secondary: "#0284C7",
        "on-secondary": "#FFFFFF",
        "secondary-container": "#BAE6FD",
        "secondary-fixed": "#E0F2FE",
        "on-secondary-fixed": "#082F49",

        tertiary: "#F59E0B",
        "tertiary-fixed-dim": "#F59E0B",
        "tertiary-fixed": "#FEF3C7",
        "on-tertiary-container": "#B45309",
        "tertiary-container": "#2A1700",

        surface: "#F8F9FF",
        "surface-container-lowest": "#FFFFFF",
        "surface-container-low": "#EFF4FF",
        "surface-container": "#E5EEFF",
        "surface-container-high": "#DCE9FF",
        "surface-container-highest": "#D3E4FE",
        "on-surface": "#0B1C30",
        "on-surface-variant": "#64748B",
        outline: "#76777D",
        "outline-variant": "#C6C6CD",

        error: "#DC2626",
        "on-error": "#FFFFFF",
        "error-container": "#FFDAD6",
        "on-error-container": "#93000A",
      },
      borderRadius: { DEFAULT: "0.125rem", lg: "0.25rem", xl: "0.5rem", full: "0.75rem" },
      spacing: {
        "space-xs": "0.25rem", "space-sm": "0.5rem", "space-md": "0.75rem",
        "space-lg": "1.25rem", "space-xl": "2rem", margin: "1rem", gutter: "1rem",
      },
      fontFamily: {
        "code-data": ["Space Grotesk"], "headline-xl": ["Space Grotesk"],
        "headline-xl-mobile": ["Space Grotesk"], "headline-lg": ["Space Grotesk"],
        "headline-md": ["Space Grotesk"], "headline-sm": ["Space Grotesk"],
        "body-lg": ["Chivo"], "body-md": ["Chivo"], "body-sm": ["Chivo"],
        "label-lg": ["Chivo"], "label-md": ["Chivo"], "label-sm": ["Chivo"],
      },
      fontSize: {
        "code-data": ["13px", { lineHeight: "18px", letterSpacing: "0.02em", fontWeight: "500" }],
        "headline-xl": ["32px", { lineHeight: "40px", letterSpacing: "-0.02em", fontWeight: "700" }],
        "headline-xl-mobile": ["26px", { lineHeight: "32px", letterSpacing: "-0.02em", fontWeight: "700" }],
        "headline-lg": ["24px", { lineHeight: "32px", letterSpacing: "-0.01em", fontWeight: "700" }],
        "headline-md": ["20px", { lineHeight: "28px", letterSpacing: "-0.01em", fontWeight: "600" }],
        "headline-sm": ["18px", { lineHeight: "24px", fontWeight: "600" }],
        "body-lg": ["16px", { lineHeight: "24px", fontWeight: "500" }],
        "body-md": ["15px", { lineHeight: "22px", fontWeight: "400" }],
        "body-sm": ["13px", { lineHeight: "18px", letterSpacing: "0.01em", fontWeight: "400" }],
        "label-lg": ["14px", { lineHeight: "20px", letterSpacing: "0.02em", fontWeight: "700" }],
        "label-md": ["12px", { lineHeight: "16px", letterSpacing: "0.04em", fontWeight: "700" }],
        "label-sm": ["11px", { lineHeight: "14px", letterSpacing: "0.05em", fontWeight: "700" }],
      },
    },
  },
};
```

Utilitas CSS pendukung (`base.css`):
```css
html, body { margin: 0; padding: 0; width: 100%; }
body { overscroll-behavior: none; }
.pb-safe { padding-bottom: env(safe-area-inset-bottom, 0px); }
.pt-safe { padding-top: env(safe-area-inset-top, 0px); }
.no-scrollbar { scrollbar-width: none; }
.no-scrollbar::-webkit-scrollbar { display: none; }
```

---

## 8. Masalah yang ditemukan di kode Stitch (perlu diperbaiki)

| # | Masalah | Perbaikan |
|---|---------|-----------|
| 1 | `no-scrollbar` dipakai tetapi tidak didefinisikan | Tambahkan utilitas di §7 |
| 2 | `clip-path-radar` dipakai di halaman Peta tetapi tidak ada | Definisikan `clip-path` atau hapus kelas |
| 3 | `z-15` bukan kelas Tailwind valid | Ganti `z-10` / `z-20` / `z-[15]` |
| 4 | Link Material Symbols dimuat 2× | Sisakan satu |
| 5 | `maximum-scale=1, user-scalable=no` menghambat aksesibilitas zoom | Hapus bila tidak benar-benar perlu |
| 6 | Latar peta berupa gambar statis (lokasi Bandung), form berlokasi Jakarta | Ganti dengan peta nyata (Leaflet/Google Maps/MapLibre) |
| 7 | Alamat Hendra Setiawan berbeda antar halaman (RT 03/05, RT 03/RW 07, RT 04/RW 03) | Satu sumber data |
| 8 | Hitungan chip (24/14/3/10) ditulis tangan; "Perlu Tindak Lanjut (3)" tidak punya kartu | Hitung dari data |
| 9 | `onclick="refreshGPS()"` memakai `event` global | Kirim `event` sebagai argumen |
| 10 | Form: validasi "Min. 10 karakter" & field wajib belum ada logika | Tambahkan validasi sebelum simpan |
| 11 | Tombol `<button>` tanpa `type` pada peta/zoom | Tambahkan `type="button"` |
| 12 | Elemen peta kecil di bawah 44px (`w-7 h-7`) | Perbesar area sentuh |

---

## 9. Aturan fitur lapangan (dari desain)

- **Foto wajib dari kamera** aplikasi; galeri dinonaktifkan. Gunakan `<input type="file" accept="image/*" capture="environment">` atau `getUserMedia`, lalu **bakar watermark ke piksel gambar** (canvas): IDPEL, tanggal-jam WIB, lat/lon. Watermark hanya overlay HTML tidak cukup untuk keaslian audit.
- **GPS wajib**: ambil lewat `navigator.geolocation.watchPosition({ enableHighAccuracy: true })`, tampilkan akurasi, dan blokir simpan jika akurasi buruk / jarak ke titik pelanggan terlalu jauh.
- **Offline-first**: simpan draft & foto di IndexedDB, tandai "belum sinkron", sinkronkan saat online; badge "Sync OK" mengikuti status nyata.
- **Data terkunci sistem** (nama, IDPEL, no. meter, tarif/daya, alamat) bersifat read-only.
- **Hanya satu hasil periksa** yang dipilih (radio) dan menentukan opsi tindak lanjut yang disarankan.

---

## 10. Checklist sebelum rilis

- [ ] Semua warna/font/ukuran memakai token, tidak ada hex/px manual
- [ ] Config Tailwind dan `base.css` terpusat
- [ ] Komponen diekstrak, tidak ada HTML kartu yang disalin-tempel
- [ ] Target sentuh ≥ 44px, kontras teks memadai
- [ ] Safe-area (`pt-safe`, `pb-safe`) berfungsi di perangkat bernotch
- [ ] Data, hitungan chip, dan status dinamis
- [ ] GPS, kamera, offline benar-benar terhubung (bukan simulasi)
- [ ] Diuji pada 360px, 390px, 430px
