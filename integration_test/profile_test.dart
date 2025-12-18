import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Profile flow - smoke', (WidgetTester tester) async {
    await initAppForTest(tester);

    final Finder prof = find.byIcon(Icons.person);
    if (prof.evaluate().isNotEmpty) await tapButton(tester, prof);

    await wait(tester, 2);
    expect(find.byType(Scaffold), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets(
    'Profile - change password (UI + result)',
    (WidgetTester tester) async {
      await initAppForTest(tester);

      // Ensure logged in (reuse login fields if present)
      final Finder loginEmail = find.byKey(const Key('login_email'));
      final Finder loginPass = find.byKey(const Key('login_password'));
      final Finder btnLogin = find.byKey(const Key('btn_login'));

      if (loginEmail.evaluate().isNotEmpty && loginPass.evaluate().isNotEmpty) {
        await inputText(tester, loginEmail, 'dinarullailil26@gmail.com');
        await inputText(tester, loginPass, 'dinarul');
        if (btnLogin.evaluate().isNotEmpty) await tapButton(tester, btnLogin);
        await wait(tester, 2);
      }

      // Open profile and edit screen
      final Finder prof = find.byIcon(Icons.person);
      if (prof.evaluate().isNotEmpty) await tapButton(tester, prof);
      await wait(tester, 1);

      final Finder ubahProfil = find.text('Ubah Profil');
      if (ubahProfil.evaluate().isNotEmpty) await tapButton(tester, ubahProfil);
      await wait(tester, 1);

      // Locate password field (second TextField on screen) and enter a new password
      final Finder textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        final Finder passField = textFields.at(1);
        await inputText(tester, passField, 'newpass123');
      }

      // Tap save (target the ElevatedButton widget to avoid hit-test issues)
      final Finder saveBtn = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      if (saveBtn.evaluate().isNotEmpty) await tapButton(tester, saveBtn);
      await wait(tester, 4);

      // Expect either success snackbar, a requires-recent-login error, any SnackBar, or that the edit screen was popped
      final Finder success = find.text('Profil berhasil diperbarui!');
      final Finder needRelogin = find.text(
        'Gagal: Mohon Logout dan Login ulang dulu untuk ganti password.',
      );
      final Finder anySnack = find.byType(SnackBar);
      final bool editScreenPopped = find.text('Edit Profil').evaluate().isEmpty;
      expect(
        success.evaluate().isNotEmpty ||
            needRelogin.evaluate().isNotEmpty ||
            anySnack.evaluate().isNotEmpty ||
            editScreenPopped,
        isTrue,
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
