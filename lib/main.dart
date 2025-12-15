import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pbl_peminjamanalatlab/screens/user/notification_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // <<< WAJIB ADA

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD

  // WAJIB untuk Web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
=======
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi Firebase 
  await Firebase.initializeApp();

>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1

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
<<<<<<< HEAD
=======

>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1
        routes: {
          '/login': (context) => const LoginScreen(),
          '/user-dashboard': (context) => const UserHomeScreen(),
          '/admin-dashboard': (context) => const AdminHomeScreen(),
          '/notifikasi': (context) => const NotificationScreen(),

        },
      ),
    );
  }
}
