import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; 

import '../admin/admin_home_screen.dart';
import '../user/user_home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); 
  }

  Future<void> _checkLoginStatus() async {
    // Tahan 3 detik
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return; 
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Belum login -> Masuk ke Onboarding (White Theme)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      // Sudah login -> Cek Role
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc.get('role');
          if (role == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const UserHomeScreen()),
            );
          }
        } else {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. BACKGROUND PUTIH (Agar serasi dengan Onboarding)
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. LOGO
            Image.asset(
              'images/log.png', // Pastikan nama file ini benar (sesuai yang kamu pakai)
              width: 300, 
              height: 300,
            ),
            
            const SizedBox(height: 40),
            
            // 3. LOADING INDICATOR UNGU
            const CircularProgressIndicator(
              // Menggunakan warna Ungu (0xFF6C63FF) agar sesuai tema
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ],
        ),
      ),
    );
  }
}