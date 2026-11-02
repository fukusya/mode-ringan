# Mode Ringan

Supaya Mac 8 GB tidak gampang hang.

- **Mode Ringan** (daun): menutup app yang jarang dipakai (bawaan: Spotify, Discord, LibreOffice, Preview, Stickies, iPhone Mirroring, PDFgear).
- **Atur Mode Ringan**: pilih sendiri app mana yang boleh ditutup Mode Ringan (Cmd + Spasi, ketik "Atur").
- **Tutup Semua** (merah): menutup semua app, bisa pilih app yang tetap dibuka.
- **Pengecek otomatis** tiap 1 menit:
  - Memori kuning → kotak 5 detik, lalu Mode Ringan jalan (bisa Batal / pilih sendiri).
  - Memori merah → kotak 30 detik, lalu Tutup Semua jalan (bisa Batal / pilih yang tetap dibuka).
- **Opsional:** pengingat restart tiap jam 8 pagi (Mac tidak restart tanpa diklik).

## Cara pasang
1. Unduh `Mode Ringan.zip` dari halaman **Releases**.
2. Buka zip, klik dua kali **Pasang Mode Ringan**.
3. Kalau muncul "pengembang tidak dikenal": System Settings → Privacy & Security → **Open Anyway**, lalu ulangi.
4. Dua tombol baru muncul di Dock. Pertama kali dipakai, klik **Allow** kalau Mac minta izin.

## Cara hapus
Klik dua kali **Hapus Mode Ringan** (ada di zip yang sama). Semua file dipindah ke Trash.

## Isi folder `isi/`
| File | Fungsi |
|---|---|
| `pasang.sh` / `hapus.sh` | Pemasang & penghapus |
| `tutup_app.sh` | Menutup app (Mode Ringan / Tutup Semua) |
| `kotak_manual.sh` | Kotak pilihan saat tombol diklik dari Dock |
| `tutup_pilihan.sh` | Menutup app yang dipilih sendiri |
| `tunggu_tutup.sh` | Menunggu app benar-benar tertutup, lalu melapor jujur |
| `cek_memori.sh` | Pengecek memori tiap 1 menit (kuning / merah) |
| `top3.sh` | Menghitung 3 app paling berat |
| `restart_pagi.sh` | Pengingat restart jam 8 pagi |
| `atur.sh` | Memilih app yang ditutup Mode Ringan (disimpan di `daftar_ringan.txt`) |
| `*.icns` | Ikon tombol |

## Cara membuat ulang zip
Pemasang (`Pasang Mode Ringan.app` & `Hapus Mode Ringan.app`) adalah AppleScript kecil yang menjalankan `isi/pasang.sh` / `isi/hapus.sh` dari dalam aplikasinya sendiri. Lihat riwayat commit untuk perintah pembuatannya.
