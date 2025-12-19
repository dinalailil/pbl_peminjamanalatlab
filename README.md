# LABIFY - Aplikasi Mobile Peminjaman Alat Laboratorium

![Flutter Version](https://img.shields.io/badge/Flutter-Stable-blue) ![Firebase](https://img.shields.io/badge/Backend-Firebase-orange) ![Platform](https://img.shields.io/badge/Platform-Android-green)

## Akses dan Instalasi Aplikasi
Aplikasi LABIFY telah melalui tahap pengembangan dan pengujian akhir, serta siap untuk didistribusikan. Pengguna dapat mengunduh berkas instalasi (APK) secara langsung melalui pemindaian Kode QR atau tautan yang tersedia di bawah ini.

*Pindai Kode QR untuk Mengunduh Langsung:*

![Kode QR Unduhan](labify_PBL.apk.png)


*Tautan Alternatif:*
[*UNDUH APLIKASI LABIFY VIA GOOGLE DRIVE*](https://drive.google.com/drive/folders/1RwqCOdwbjhIuICtskyRz97IphvlxJJdV?usp=sharing)

---

## Deskripsi Sistem
*LABIFY* merupakan solusi perangkat lunak berbasis seluler yang dirancang khusus untuk memodernisasi tata kelola peminjaman inventaris laboratorium di lingkungan akademik. Sistem ini dikembangkan untuk mengeliminasi inefisiensi pencatatan manual dan meningkatkan akurasi data inventaris.

Sistem ini mengadopsi arsitektur berbasis peran (Role-Based Access Control) yang memisahkan antarmuka dan hak akses antara *User* sebagai pengguna layanan dan *Admin* sebagai administrator sistem. Integrasi dengan layanan Firebase memastikan integritas data dan pemantauan ketersediaan alat dapat dilakukan secara waktu nyata (real-time).

---

## Fitur Unggulan

### Modul User (Pengguna)
* *Katalog Inventaris Digital:* Akses komprehensif terhadap daftar alat laboratorium, mencakup spesifikasi teknis, visualisasi alat, dan informasi ketersediaan stok di setiap laboratorium.
* *Sistem Peminjaman Terintegrasi:* Mekanisme pengajuan peminjaman yang efisien dengan validasi formulir digital untuk pemilihan tanggal dan durasi peminjaman.
* *Pemantauan Status Real-Time:* Transparansi proses pengajuan melalui notifikasi status persetujuan yang terbarui secara otomatis.
* *Arsip Transaksi:* Rekam jejak digital seluruh aktivitas peminjaman yang telah dilakukan oleh pengguna untuk keperluan audit pribadi.
* *Manajemen Profil:* Pengelolaan data identitas pengguna yang aman dan terstruktur.

### Modul Administrator (Admin Lab)
* *Dasbor Analitik:* Visualisasi ringkas mengenai aktivitas peminjaman yang sedang berlangsung untuk mendukung pengambilan keputusan operasional.
* *Manajemen Inventaris:* Kontrol penuh untuk pembaruan data aset, penambahan unit baru, serta penyesuaian informasi teknis alat.
* *Sistem Validasi:* Otoritas untuk meninjau, menyetujui, atau menolak permohonan peminjaman berdasarkan ketersediaan dan kebijakan laboratorium.
* *Penyelesaian Transaksi:* Prosedur verifikasi pengembalian alat yang secara otomatis memperbarui jumlah stok dalam pangkalan data.
* *Audit Peminjam:* Akses terhadap riwayat peminjaman spesifik per mahasiswa untuk evaluasi kepatuhan pengguna.

---

## Spesifikasi Teknis
Aplikasi ini dibangun di atas fondasi teknologi modern untuk menjamin performa tinggi, skalabilitas, dan pengalaman pengguna yang responsif.

* *Kerangka Kerja (Framework):* Flutter (Dart Language)
* *Backend & Basis Data:* Google Firebase (Authentication & Cloud Firestore)
* *Arsitektur Perangkat Lunak:* MVVM (Model-View-ViewModel).
* *Lingkungan Pengembangan:* Visual Studio Code, Android Studio

---

## Panduan Instalasi Kode Sumber
Bagian ini ditujukan bagi pengembang yang ingin meninjau atau mengembangkan lebih lanjut kode sumber LABIFY di lingkungan lokal.

### Prasyarat Sistem
* Flutter SDK (Versi Stabil Terbaru)
* Android Studio atau Visual Studio Code
* Koneksi Internet (Diperlukan untuk sinkronisasi Firebase)

### Prosedur Instalasi
1.  *Kloning Repositori*
    Salin repositori proyek ke direktori lokal menggunakan perintah berikut:
    bash
    git clone [https://github.com/USERNAME_ANDA/NAMA_REPO_ANDA.git](https://github.com/USERNAME_ANDA/NAMA_REPO_ANDA.git)
    

2.  *Navigasi Direktori*
    Masuk ke dalam folder proyek yang telah disalin:
    bash
    cd NAMA_REPO_ANDA
    

3.  *Instalasi Dependensi*
    Unduh seluruh pustaka dan dependensi yang diperlukan oleh sistem:
    bash
    flutter pub get
    

4.  *Eksekusi Aplikasi*
    Jalankan aplikasi pada emulator atau perangkat fisik yang terhubung:
    bash
    flutter run
    

---

## Tim Pengembang (Kelompok 4)
Proyek ini dikembangkan oleh tim yang solid dan bekerja bersama.

* *Aidatul Rosida* 
* *Dinarul Lailil Mubarokah* 
* *Ivan Rizal Ahmadi*
* *Luthfi Putra Mahardika* 
* *Mochamad Zacky Yudha A* 

---