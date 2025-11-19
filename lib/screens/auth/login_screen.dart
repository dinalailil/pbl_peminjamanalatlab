import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/textfield_email_widget.dart';
import '../../widgets/textfield_pass_widget.dart';
import '../../widgets/textfield_nama_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT (Modern Blue-Purple)
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA), // Royal Blue lembut
                  Color(0xFF764BA2), // Deep Purple
                ],
              ),
            ),
          ),

          // 2. DEKORASI LINGKARAN (Agar tidak sepi)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -20,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 3. KONTEN UTAMA (Center Card)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- JUDUL & LOGO ---
                  const Icon(Icons.school_rounded, size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    authProvider.isLogin ? "Hello Again!" : "Join Us!",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    authProvider.isLogin 
                      ? "Welcome back, you've been missed!" 
                      : "Create an account to get started",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- CARD FORM (GLASS EFFECT) ---
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: authProvider.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul Kecil di dalam Card
                          Text(
                            authProvider.isLogin ? "Login" : "Register",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Field Nama
                          if (!authProvider.isLogin) ...[
                            TextfieldNamaWidget(controller: authProvider.namaCtrl),
                            const SizedBox(height: 16),
                          ],

                          // Field Email
                          TextfieldEmailWidget(controller: authProvider.emailCtrl),
                          const SizedBox(height: 16),

                          // Field Password
                          TextfieldPasswordWidget(controller: authProvider.passCtrl),
                          
                          const SizedBox(height: 10),
                          // Lupa Password (Hiasan saja dulu)
                          if (authProvider.isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),

                          // --- TOMBOL UTAMA (GRADIENT BUTTON) ---
                          authProvider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Container(
                                  width: double.infinity,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF667EEA).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => authProvider.submit(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      authProvider.isLogin ? "Sign In" : "Sign Up",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- TOGGLE LOGIN/REGISTER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        authProvider.isLogin 
                          ? "Not a member? " 
                          : "Already have an account? ",
                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () => authProvider.toggleLogin(),
                        child: Text(
                          authProvider.isLogin ? "Register now" : "Login",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            decoration: TextDecoration.underline, // Garis bawah biar jelas
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}