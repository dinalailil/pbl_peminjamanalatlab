import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pbl_peminjamanalatlab/firebase_options.dart';
import 'package:pbl_peminjamanalatlab/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

final IntegrationTestWidgetsFlutterBinding binding =
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

Future<void> initAppForTest(WidgetTester tester) async {
  // Initialize locale for date formatting (id_ID untuk Indonesia)
  await initializeDateFormatting('id_ID');

  await tester.runAsync(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  // If onboarding is shown, dismiss it so tests start from Login/Home
  final skipFinder = find.byKey(const Key('onboarding_skip'));
  final nextFinder = find.byKey(const Key('onboarding_next'));
  final loginEmailFinder = find.byKey(const Key('login_email'));

  if (skipFinder.evaluate().isNotEmpty) {
    await tester.tap(skipFinder);
    await tester.pumpAndSettle();
  } else {
    // Press "Lanjut"/"Mulai" until login screen appears or the button disappears
    int safety = 0;
    while (nextFinder.evaluate().isNotEmpty &&
        loginEmailFinder.evaluate().isEmpty &&
        safety < 10) {
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      safety++;
    }
  }
}

Future<void> wait(WidgetTester tester, int seconds) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle(Duration(seconds: seconds));
}

Future<void> inputText(WidgetTester tester, Finder finder, String text) async {
  if (finder.evaluate().isEmpty) return;
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

Future<void> tapButton(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) return;
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
  try {
    await tester.tap(finder);
  } catch (e) {
    // Fallback: tap at the center of the first matched render box
    final renderBox = tester.firstRenderObject(finder) as RenderBox;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final center = topLeft + renderBox.size.center(Offset.zero);
    await tester.tapAt(center);
  }
  await tester.pumpAndSettle();
}
