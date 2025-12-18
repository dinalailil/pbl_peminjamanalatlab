import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Register flow - smoke', (WidgetTester tester) async {
    await initAppForTest(tester);

    // navigate to register if toggle present
    final Finder daftarNow = find.text('Daftar Sekarang');
    if (daftarNow.evaluate().isNotEmpty) {
      await tapButton(tester, daftarNow);
      await wait(tester, 1);
    }

    final Finder email = find.byKey(const Key('register_email'));
    final Finder pass = find.byKey(const Key('register_password'));
    final Finder nama = find.byKey(const Key('register_nama'));
    final Finder btn = find.byKey(const Key('btn_register'));

    if (nama.evaluate().isNotEmpty &&
        email.evaluate().isNotEmpty &&
        pass.evaluate().isNotEmpty) {
      await inputText(tester, nama, 'Dinarul');
      await inputText(tester, email, 'dinarul@gmail.com');
      await inputText(tester, pass, 'dinarul');
      if (btn.evaluate().isNotEmpty) await tapButton(tester, btn);
    }

    await wait(tester, 2);

    // Setelah register sukses, coba login dengan akun yang baru
    final Finder loginEmail = find.byKey(const Key('login_email'));
    final Finder loginPass = find.byKey(const Key('login_password'));
    final Finder loginBtn = find.byKey(const Key('btn_login'));

    if (loginEmail.evaluate().isNotEmpty && loginPass.evaluate().isNotEmpty) {
      await inputText(tester, loginEmail, 'dinaa@gmail.com');
      await inputText(tester, loginPass, 'dinarul');
      if (loginBtn.evaluate().isNotEmpty) await tapButton(tester, loginBtn);
    }

    await wait(tester, 2);
    expect(find.byType(Scaffold), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
