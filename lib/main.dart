import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import semua file yang dibutuhkan
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase (WAJIB)
  await Firebase.initializeApp();

  // Inisialisasi Locale untuk tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aplikasi Peminjaman',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: false,
        ),
        home: const SplashScreen(),

        routes: {
          '/login': (context) => const LoginScreen(),
          '/user-dashboard': (context) => const UserHomeScreen(),
          '/admin-dashboard': (context) => const AdminHomeScreen(),
        },
      ),
    );
  }
}
