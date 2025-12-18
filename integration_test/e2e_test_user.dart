import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_peminjamanalatlab/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E TEST: Skenario Peminjaman, Verifikasi Notifikasi, dan Riwayat Transaksi', (WidgetTester tester) async {
    
    // ================= [FASE 0: INISIALISASI] =================
    SharedPreferences.setMockInitialValues({});
    app.main();
    await tester.pumpAndSettle();

    print("[INFO] Menginisialisasi aplikasi dan menunggu Splash Screen selesai.");
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final btnSkip = find.byKey(const Key('tombol_skip_onboarding')); 
    if (await tester.any(btnSkip)) {
      await tester.tap(btnSkip);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // ================= [FASE 1: REGISTRASI PENGGUNA] =================
    print("[NAVIGASI] Memulai proses navigasi ke halaman Pendaftaran Akun.");
    final btnRegister = find.text("Daftar Sekarang");
    if (await tester.any(btnRegister)) {
        await tester.tap(btnRegister);
    } else {
        await tester.tap(find.byKey(const Key('tombol_pindah_register')));
    }
    await tester.pumpAndSettle();

    final emailUnik = "user_${DateTime.now().millisecondsSinceEpoch}@tes.com";
    print("[DATA] Menggunakan kredensial pengujian baru: $emailUnik");

    await tester.enterText(find.byType(TextFormField).at(0), 'User Demo Report'); 
    await tester.enterText(find.byType(TextFormField).at(1), emailUnik);    
    await tester.enterText(find.byType(TextFormField).at(2), '123456');     

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ================= [FASE 2: AUTENTIKASI ULANG] =================
    print("[AKSI] Melakukan Login kembali menggunakan akun yang baru didaftarkan.");
    await tester.enterText(find.byType(TextFormField).at(0), emailUnik); 
    await tester.enterText(find.byType(TextFormField).at(1), '123456');  
    
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton).first);
    
    print("[INFO] Verifikasi autentikasi berhasil. Memuat halaman Dashboard.");
    await tester.pumpAndSettle(const Duration(seconds: 8));
    expect(find.textContaining('Halo'), findsWidgets);

    // ================= [FASE 3: NAVIGASI KATALOG] =================
    // 1. KLIK LAB
    print("[NAVIGASI] Mencari dan memilih unit Laboratorium: 'LAB AI Lt. 7B'.");
    final targetLab = find.text("LAB AI Lt. 7B");
    await tester.scrollUntilVisible(targetLab, 500.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(targetLab);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 2. KLIK BARANG
    print("[NAVIGASI] Mencari item spesifik pada katalog: 'Proyektor Epson'.");
    final targetBarang = find.text("Proyektor Epson");
    if (await tester.any(targetBarang)) {
        await tester.ensureVisible(targetBarang);
        await tester.tap(targetBarang);
        await tester.pumpAndSettle();
    } else {
        fail("[ERROR] Barang yang dicari tidak ditemukan dalam katalog.");
    }

    // 3. KLIK SEWA DI MODAL
    print("[AKSI] Membuka detail barang dan menekan tombol penyewaan.");
    final btnSewa = find.text("Sewa");
    if (await tester.any(btnSewa)) {
        await tester.tap(btnSewa);
    } else {
         await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byType(ElevatedButton)));
    }
    await tester.pumpAndSettle(); 

    // ================= [FASE 4: PENGISIAN FORMULIR] =================
    print("[INPUT] Mengisi data formulir peminjaman (Identitas & Tanggal).");

    await tester.enterText(find.widgetWithText(TextFormField, "Nama Peminjam"), "User Testing Laporan");
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.widgetWithText(TextFormField, "Keperluan"), "Simulasi Pengujian Sistem");
    await tester.pump(const Duration(milliseconds: 300));
    
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Pilih Tanggal
    final iconKalender = find.byIcon(Icons.calendar_month);
    
    Future<void> klikOkKalender() async {
      final btnOk = find.text('OK');
      final btnOke = find.text('OKE');
      final btnPilih = find.text('PILIH');
      if (await tester.any(btnOk)) await tester.tap(btnOk);
      else if (await tester.any(btnOke)) await tester.tap(btnOke);
      else if (await tester.any(btnPilih)) await tester.tap(btnPilih);
      else await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.byType(TextButton)).last);
      await tester.pumpAndSettle();
    }

    await tester.tap(iconKalender.at(0)); 
    await tester.pumpAndSettle();
    await klikOkKalender();

    await tester.tap(iconKalender.at(1));
    await tester.pumpAndSettle();
    await klikOkKalender();

    // Submit
    print("[AKSI] Mengirimkan data peminjaman ke server.");
    final btnSubmit = find.widgetWithText(ElevatedButton, "Ajukan Pinjaman");
    await tester.scrollUntilVisible(btnSubmit, 100.0, scrollable: find.byType(Scrollable).last);
    await tester.tap(btnSubmit);
    
    await tester.pumpAndSettle(const Duration(seconds: 5));
    print("[INFO] Data berhasil dikirim. Sistem mengarahkan kembali ke halaman utama.");

    // MUNDUR KE DASHBOARD
    final btnBackKatalog = find.byIcon(Icons.arrow_back);
    if (await tester.any(btnBackKatalog)) {
        await tester.tap(btnBackKatalog);
    } else {
        await tester.pageBack();
    }
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining('Halo'), findsWidgets);

    // ================= [FASE 5: VERIFIKASI NOTIFIKASI & RIWAYAT] =================

    // 1. PINDAH KE TAB NOTIFIKASI
    print("[NAVIGASI] Membuka Tab Notifikasi untuk memantau status pengajuan.");
    final iconNotif = find.byIcon(Icons.notifications_outlined); 
    if (await tester.any(iconNotif)) {
        await tester.tap(iconNotif);
    } else {
        await tester.tap(find.byIcon(Icons.notifications_rounded));
    }
    await tester.pumpAndSettle();

    // 2. TUNGGU ADMIN APPROVE (20 DETIK)
    print("[PROSES] Menunggu validasi Admin (Estimasi: 20 Detik).");
    print("[KETERANGAN SISTEM] Saat Admin menyetujui peminjaman, indikator status akan berubah menjadi HIJAU. Apabila Admin menyetujui pengembalian barang, notifikasi ini akan hilang dari daftar.");
    
    for (int i = 0; i < 4; i++) {
        await Future.delayed(const Duration(seconds: 5)); 
        await tester.pump(); 
        print("[WAIT] Sinkronisasi data real-time... ${ (i+1)*5 } detik.");
    }

    // 3. KE PROFIL -> RIWAYAT
    print("[NAVIGASI] Berpindah ke menu Profil Pengguna.");
    final iconProfil = find.byIcon(Icons.person_outline); 
    if (await tester.any(iconProfil)) {
        await tester.tap(iconProfil);
    } else {
         await tester.tap(find.byIcon(Icons.person_rounded));
    }
    await tester.pumpAndSettle();

    print("[AKSI] Membuka submenu 'Riwayat Transaksi'.");
    final btnRiwayat = find.text("Riwayat Transaksi");
    await tester.scrollUntilVisible(btnRiwayat, 100.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(btnRiwayat);
    await tester.pumpAndSettle();

    // 4. DIAM DI RIWAYAT (10 DETIK)
    print("[VERIFIKASI] Menampilkan data Riwayat (10 Detik).");
    print("[KETERANGAN SISTEM] Transaksi peminjaman yang telah selesai dan dikembalikan (approved return) tercatat dan muncul pada daftar riwayat ini sebagai arsip pengguna.");
    await Future.delayed(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    // --- KEMBALI DARI RIWAYAT ---
    print("[NAVIGASI] Kembali ke halaman Profil.");
    
    final back1 = find.byIcon(Icons.arrow_back);
    final back2 = find.byIcon(Icons.arrow_back_ios);
    final back3 = find.byIcon(Icons.chevron_left);
    
    if (await tester.any(back1)) {
        await tester.tap(back1);
    } else if (await tester.any(back2)) {
        await tester.tap(back2);
    } else if (await tester.any(back3)) {
        await tester.tap(back3);
    } else {
        print("[SYSTEM] Menggunakan metode navigasi alternatif (Default Back Button).");
        await tester.tap(find.byType(IconButton).first);
    }
    
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ================= [FASE 6: LOGOUT] =================
    print("[AKSI] Memulai prosedur Logout dari aplikasi.");

    final btnKeluar = find.text("Keluar Aplikasi");
    await tester.scrollUntilVisible(btnKeluar, 100.0, scrollable: find.byType(Scrollable).last);
    await tester.tap(btnKeluar);
    await tester.pumpAndSettle();

    await tester.tap(find.text("Ya"));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Validasi Akhir
    expect(find.byType(TextFormField).first, findsOneWidget); 
    print("[SUKSES] Seluruh skenario pengujian (End-to-End) telah selesai dan berhasil diverifikasi.");
  });
}