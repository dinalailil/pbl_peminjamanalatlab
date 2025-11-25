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
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA), // Ungu Muda
                  Color(0xFF764BA2), // Merah Tua
                ],
              ),
            ),
          ),

          // 2. DEKORASI LINGKARAN
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

          // 3. KONTEN UTAMA (SOLUSI OVERFLOW & CENTER)
          // Gunakan LayoutBuilder agar konten tahu tinggi layar
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // ConstrainedBox memaksa tinggi minimal setinggi layar
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Rata Tengah Vertikal
                      children: [
                        // --- LOGO SAJA (Tanpa Teks) ---
                        Image.asset(
                          'images/peminjamanlab.png', 
                          width: 180, // Ukuran pas (tidak terlalu besar/kecil)
                          height: 180,
                        ),
                        
                        const SizedBox(height: 10), // Jarak aman ke Form

                        // --- KARTU FORM ---
                        Container(
                          padding: const EdgeInsets.all(20),
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
                                  authProvider.isLogin ? "Silakan Masuk" : "Buat Akun Baru",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Field Nama (Hanya saat Register)
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
                                
                                // Lupa Password
                                if (authProvider.isLogin)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Lupa Password?",
                                      style: TextStyle(
                                        color: const Color(0xFF8E78FF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 30),

                                // Tombol Utama
                                authProvider.isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : Container(
                                        width: double.infinity,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF8E78FF), Color(0xFFDD2476)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFDD2476).withOpacity(0.4),
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
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            authProvider.isLogin ? "Masuk" : "Daftar",
                                            style: const TextStyle(
                                              fontSize: 16,
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

                        const SizedBox(height: 25),

                        // Toggle Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              authProvider.isLogin 
                                ? "Belum punya akun? " 
                                : "Sudah punya akun? ",
                              style: const TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            GestureDetector(
                              onTap: () => authProvider.toggleLogin(),
                              child: Text(
                                authProvider.isLogin ? "Daftar Sekarang" : "Login Disini",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}