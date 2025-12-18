import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Peminjaman flow - smoke', (WidgetTester tester) async {
    await initAppForTest(tester);

    // 1. LOGIN DULU
    final Finder loginEmail = find.byKey(const Key('login_email'));
    final Finder loginPass = find.byKey(const Key('login_password'));
    final Finder loginBtn = find.byKey(const Key('btn_login'));

    if (loginEmail.evaluate().isNotEmpty && loginPass.evaluate().isNotEmpty) {
      await inputText(tester, loginEmail, 'dinarullailil26@gmail.com');
      await inputText(tester, loginPass, 'dinarul');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.ensureVisible(loginBtn.first);
        await tester.pumpAndSettle();
        await tapButton(tester, loginBtn);
      }
    }

    await wait(tester, 2);

    // 2. MILIH LAB - cari 'LAB AI Lt.7B' dengan beberapa variasi, fallback ke predicate
    final List<String> labCandidates = [
      'LAB AI Lt.7B',
      'LAB AI2 Lt. 7B',
      'Lab Jaringan Lt.7B',
      'Lab Multimedia Lt. 7B',
    ];

    bool tappedLab = false;
    for (final name in labCandidates) {
      final f = find.text(name);
      if (f.evaluate().isNotEmpty) {
        await tester.ensureVisible(f.first);
        await tester.pumpAndSettle();
        await tapButton(tester, f);
        tappedLab = true;
        break;
      }
    }

    if (!tappedLab) {
      // Fallback: cari nama lab yang mengandung 'AI' dan '7'
      final Finder labFinder = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final t = (widget.data ?? '').toString().toLowerCase();
          return t.contains('ai') && t.contains('7');
        }
        return false;
      });
      if (labFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(labFinder.first);
        await tester.pumpAndSettle();
        await tapButton(tester, labFinder.first);
        tappedLab = true;
      }
    }

    if (tappedLab) await wait(tester, 2);

    await wait(tester, 1);

    // 3. Pastikan kita ada di CatalogScreen
    final Finder katalogTitle = find.text('Katalog Barang');
    if (katalogTitle.evaluate().isNotEmpty) {
      // Cari item pertama di GridView (item cards are InkWell)
      final Finder grid = find.byType(GridView);
      final Finder itemInk = find.byWidgetPredicate((w) {
        if (w is InkWell && w.key != null) {
          return w.key.toString().contains('item_');
        }
        return false;
      });
      if (itemInk.evaluate().isNotEmpty) {
        await tester.ensureVisible(itemInk.first);
        await tester.pumpAndSettle();
        await tapButton(tester, itemInk.first);
        await wait(tester, 1);
      }
    }

    // 4. KLIK SEWA (btn_pinjam) di modal
    final Finder pinjamBtn = find.byKey(const Key('btn_pinjam'));
    if (pinjamBtn.evaluate().isNotEmpty) await tapButton(tester, pinjamBtn);

    await wait(tester, 1);

    // 5. ISI FORM PEMINJAMAN (tanggal mulai, tanggal akhir, catatan, dll)
    // Cari field-field form sewa
    final Finder tglMulaiField = find.byKey(const Key('tgl_mulai'));
    final Finder tglAkhirField = find.byKey(const Key('tgl_akhir'));
    final Finder namaField = find.byKey(const Key('nama_peminjam'));
    final Finder catatanField = find.byKey(const Key('catatan_pinjam'));
    final Finder submitBtn = find.byKey(const Key('btn_submit_pinjam'));

    // Isi form jika ada
    final List<String> okVariants = ['OK', 'Ok', 'ok', 'Oke', 'OKE'];

    // Pick start date and confirm the datepicker dialog
    if (tglMulaiField.evaluate().isNotEmpty) {
      await tapButton(tester, tglMulaiField);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Try to tap OK variants a few times
      for (int attempt = 0; attempt < 4; attempt++) {
        for (final v in okVariants) {
          final Finder okFinder = find.text(v);
          if (okFinder.evaluate().isNotEmpty) {
            await tapButton(tester, okFinder);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          }
        }
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }
      await wait(tester, 1);
    }

    // Pick end date and confirm
    if (tglAkhirField.evaluate().isNotEmpty) {
      await tapButton(tester, tglAkhirField);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      for (int attempt = 0; attempt < 4; attempt++) {
        for (final v in okVariants) {
          final Finder okFinder = find.text(v);
          if (okFinder.evaluate().isNotEmpty) {
            await tapButton(tester, okFinder);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          }
        }
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }
      await wait(tester, 1);
    }

    // Isi nama peminjam jika tersedia
    if (namaField.evaluate().isNotEmpty) {
      await inputText(tester, namaField, 'Dinar Test');
      await wait(tester, 1);
    }

    if (catatanField.evaluate().isNotEmpty) {
      await inputText(tester, catatanField, 'Untuk presentasi');
    }

    // Submit form
    if (submitBtn.evaluate().isNotEmpty) {
      await tapButton(tester, submitBtn);

      // Wait for confirmation: either success snackbar or the form to be popped
      bool success = false;
      for (int i = 0; i < 10; i++) {
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        if (find.text('Berhasil diajukan!').evaluate().isNotEmpty) {
          success = true;
          break;
        }
        // Or submit button disappeared (form popped)
        if (submitBtn.evaluate().isEmpty) {
          success = true;
          break;
        }
      }

      expect(
        success,
        isTrue,
        reason: 'Form submission did not complete (no confirmation)',
      );
    }

    await wait(tester, 2);
    expect(find.byType(Scaffold), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
