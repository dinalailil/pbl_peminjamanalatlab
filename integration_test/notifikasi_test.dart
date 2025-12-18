import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'common.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/src/timestamp.dart'
    as _ts; // for Timestamp

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Notifikasi flow - smoke', (WidgetTester tester) async {
    await initAppForTest(tester);

    // 1) Login (reuse existing test account)
    final Finder loginEmail = find.byKey(const Key('login_email'));
    final Finder loginPass = find.byKey(const Key('login_password'));
    final Finder loginBtn = find.byKey(const Key('btn_login'));

    if (loginEmail.evaluate().isNotEmpty && loginPass.evaluate().isNotEmpty) {
      await inputText(tester, loginEmail, 'dinarullailil26@gmail.com');
      await inputText(tester, loginPass, 'dinarul');
      if (loginBtn.evaluate().isNotEmpty) {
        await tapButton(tester, loginBtn);
      }
    }

    await wait(tester, 3);

    // 2) Create a test notification in Firestore for the current user
    // Try sign-in programmatically first (more reliable than UI taps)
    await tester.runAsync(() async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'dinarullailil26@gmail.com',
          password: 'dinarul',
        );
      } catch (e) {
        // ignore - may already be signed in or UI login used
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // Remove any previous test notifications for this user to avoid duplicates
          final QuerySnapshot existing = await FirebaseFirestore.instance
              .collection('peminjaman')
              .where('user_uid', isEqualTo: user.uid)
              .where('kode_barang', isEqualTo: 'TESTNOTIF001')
              .get();
          for (var doc in existing.docs) {
            try {
              await doc.reference.delete();
            } catch (_) {}
          }

          await FirebaseFirestore.instance.collection('peminjaman').add({
            'user_uid': user.uid,
            'kode_barang': 'TESTNOTIF001',
            'nama_barang': 'Notif Test Item',
            'gambar':
                'https://tse3.mm.bing.net/th/id/OIP.OeOqeXR8-0NM-913ZQOQuQHaEJ?pid=Api&P=0&h=180',
            'jumlah_pinjam': 1,
            'tgl_pinjam': Timestamp.now(),
            'tgl_kembali': Timestamp.now(),
            'status': 'disetujui',
            'created_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // ignore write errors in test environment
        }
      }
    });

    // Wait for Firestore propagation and allow UI to rebuild after programmatic sign-in
    await tester.pumpAndSettle();
    // Wait longer to give serverTimestamp time to be written and synced
    await wait(tester, 6);

    // 3) Open notification tab via bottom nav (try several icon variants)
    final Finder notifRounded = find.byIcon(Icons.notifications_rounded);
    final Finder notifOutlined = find.byIcon(Icons.notifications_outlined);
    final Finder notifPlain = find.byIcon(Icons.notifications);

    if (notifRounded.evaluate().isNotEmpty) {
      await tapButton(tester, notifRounded);
    } else if (notifOutlined.evaluate().isNotEmpty) {
      await tapButton(tester, notifOutlined);
    } else if (notifPlain.evaluate().isNotEmpty) {
      await tapButton(tester, notifPlain);
    }

    await wait(tester, 3);

    // Assert the created notification appears
    expect(find.textContaining('TESTNOTIF001'), findsWidgets);
    expect(find.textContaining('Proses Disetujui'), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
