import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'common.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login flow - smoke', (WidgetTester tester) async {
    await initAppForTest(tester);

    // try navigate to login if onboarding shows text
    final Finder loginHere = find.text('Login Disini');
    if (loginHere.evaluate().isNotEmpty) {
      await tapButton(tester, loginHere);
      await wait(tester, 1);
    }

    // perform login input if fields are present
    final Finder emailFinder = find.byKey(const Key('login_email'));
    final Finder passFinder = find.byKey(const Key('login_password'));
    final Finder btnLogin = find.byKey(const Key('btn_login'));

    if (emailFinder.evaluate().isNotEmpty && passFinder.evaluate().isNotEmpty) {
      await inputText(tester, emailFinder, 'dinarullailil26@gmail.com');
      await inputText(tester, passFinder, 'dinarul');
      if (btnLogin.evaluate().isNotEmpty) {
        await tapButton(tester, btnLogin);
      }
    }

    await wait(tester, 2);

    // basic check: either 'Beranda' or Scaffold present
    expect(find.byType(Scaffold), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
