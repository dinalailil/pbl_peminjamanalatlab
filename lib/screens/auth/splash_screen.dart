import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; 
import '../admin/admin_home_screen.dart';
import '../user/user_home_screen.dart';
import 'login_screen.dart';

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
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return; 
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E78FF), 
              Color(0xFFDD2476), 
            ],
          ),
        ),
        child: Center( // Tambahkan Widget Center di sini untuk memastikan seluruh Column ada di tengah
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- LOGO BARU KAMU ---
              Image.asset(
                'images/lab.png', 
                // PERBESAR UKURANNYA
                width: 300, // Dulu 180, sekarang 280 (bisa disesuaikan lagi)
                height: 300,
              ),
              
              // HAPUS Saja Text "PEMLAB" yang Ganda, karena sudah ada di logomu
              // const SizedBox(height: 20),
              // const Text(
              //   "PEMLAB",
              //   style: TextStyle(
              //     fontSize: 28, 
              //     fontWeight: FontWeight.bold, 
              //     color: Colors.white,
              //     letterSpacing: 2,
              //   ),
              // ),
              
              const SizedBox(height: 40),
              
              // Loading Indicator Putih
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}