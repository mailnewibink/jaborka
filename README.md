# jaborka - International Cargo Service

Website resmi dan portal admin untuk **jaborka (jbrk)** - Jasa Pengiriman Kargo & Impor Borongan Door to Door Internasional.

## Fitur Utama

- **Website Publik (`/`):**
  - Hero section interaktif dengan animasi 3D container & parallax (GSAP).
  - Kalkulator simulasi tarif kargo udara & laut secara otomatis.
  - Tabel katalog tarif resmi multi-negara (Guangzhou, Yiwu, Singapore, Bangkok, Korea, Hongkong, Shanghai, Taiwan, Australia).
  - Ketentuan operasional, pengecualian klaim, dan kontak CS.
- **Admin Panel (`/admin`):**
  - Manajemen katalog harga & estimasi rute.
  - **PUBLISH RATE & Markup Otomatis**:
    - Via Laut: Otomatis markup $+ \text{Rp } 1.000.000 / \text{m}^3$.
    - Via Udara: Otomatis markup $+ \text{Rp } 20.000 / \text{Kg}$ (Min. pengiriman 2 KG).
  - Navigasi responsif antar 9 negara asal tanpa terpotong (tab wrapping, quick dropdown selector, dan prev/next country buttons).
  - Auto-sync real-time ke database `pricing.json` dan website publik.

## Cara Menjalankan

Jalankan server Node.js:

```bash
npm start
# atau
node server.js
```

Akses melalui browser:
- Website: [http://localhost:3000/](http://localhost:3000/)
- Admin Panel: [http://localhost:3000/admin](http://localhost:3000/admin)
