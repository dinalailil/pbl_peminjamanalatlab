import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Warna Tema (Ungu Labify)
  final Color primaryColor = const Color(0xFF6C63FF); 
  final Color darkPurple = const Color(0xFF4834DF);

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "images/ilustration.png", 
      "title": "Selamat Datang\ndi Labify",
      "desc": "Aplikasi peminjaman alat laboratorium terlengkap dan termudah untuk mahasiswa Polinema."
    },
    {
      "image": "images/boom.png", 
      "title": "Pinjam Alat\nTanpa Ribet",
      "desc": "Cukup cari alat, ajukan peminjaman, dan tunggu persetujuan admin. Semua dalam genggaman!"
    },
    {
      "image": "images/log.png", 
      "title": "Siap Memulai\nPetualangan?",
      "desc": "Bergabunglah sekarang dan nikmati kemudahan akses fasilitas laboratorium kampus."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 1. BACKGROUND PUTIH BERSIH
      body: Stack(
        children: [
          // 2. DEKORASI LINGKARAN (Ungu Pudar Tipis - Agar tidak terlalu polos)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05), // Ungu sangat tipis
                shape: BoxShape.circle
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05), 
                shape: BoxShape.circle
              ),
            ),
          ),

          // 3. KONTEN UTAMA
          SafeArea(
            child: Column(
              children: [
                // TOMBOL SKIP (Teks Ungu)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: TextButton(
                      onPressed: () => _goToLogin(),
                      child: Text(
                        "Lewati",
                        style: TextStyle(
                          color: primaryColor, // Warna Ungu
                          fontSize: 16, 
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ),

                // PAGE VIEW
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingData.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) => _buildPageContent(
                      image: _onboardingData[index]["image"]!,
                      title: _onboardingData[index]["title"]!,
                      desc: _onboardingData[index]["desc"]!,
                    ),
                  ),
                ),

                // BAGIAN BAWAH
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // INDIKATOR TITIK (Toggle Ungu)
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => _buildDot(index),
                        ),
                      ),

                      // TOMBOL NEXT (Background Ungu, Teks Putih)
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _goToLogin(); 
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor, // Tombol Ungu Solid
                          foregroundColor: Colors.white, // Teks Putih
                          elevation: 5,
                          shadowColor: primaryColor.withOpacity(0.4), // Bayangan ungu
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _onboardingData.length - 1 ? "Mulai" : "Lanjut",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildPageContent({required String image, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gambar (Tanpa Shadow kotak, agar bersih di background putih)
          Image.asset(
            image, 
            height: 280,
            fit: BoxFit.contain,
          ),
          
          const SizedBox(height: 50),
          
          // Judul (Warna Hitam/Ungu Gelap)
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkPurple, // Ungu Gelap agar kontras
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Deskripsi (Warna Abu-abu)
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey, // Abu-abu agar enak dibaca
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Indikator Titik (Ungu vs Abu)
  Widget _buildDot(int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        height: 8,
        // Titik aktif lebih panjang
        width: _currentPage == index ? 30 : 8, 
        decoration: BoxDecoration(
          // Aktif = Ungu, Tidak Aktif = Abu-abu muda
          color: _currentPage == index ? primaryColor : Colors.grey[300], 
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}