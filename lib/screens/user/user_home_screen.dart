import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'form_peminjaman_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // State untuk mengecek apakah menu sedang terbuka atau tertutup
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu sangat muda
      body: Column(
        children: [
          // --- 1. HEADER DINAMIS (Sesuai Figma) ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 300), // Animasi halus
            curve: Curves.easeInOut,
            width: double.infinity,
            // Jika menu buka, header agak lebih tinggi sedikit biar muat listnya
            height: _isMenuOpen ? size.height * 0.55 : size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8E78FF), // Ungu muda (atas)
                  Color(0xFF764BA2), // Ungu tua (bawah)
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- BARIS ATAS (Avatar + Nama + Tombol Menu) ---
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.person, color: Colors.grey, size: 30),
                        ),
                        const SizedBox(width: 15),
                        
                        // Stream Nama User
                        Expanded(
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user?.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              String namaUser = "Loading...";
                              if (snapshot.hasData && snapshot.data!.exists) {
                                var data = snapshot.data!.data() as Map<String, dynamic>;
                                namaUser = data['nama'] ?? "User";
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Halo $namaUser",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Jika menu tertutup, tampilkan slogan. Jika terbuka, tampilkan tanggal kecil
                                  if (_isMenuOpen)
                                     const Text(
                                      "Selasa, 18 November 2025",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    )
                                ],
                              );
                            },
                          ),
                        ),

                        // Tombol Burger Menu (Untuk Buka/Tutup)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isMenuOpen = !_isMenuOpen;
                            });
                          },
                          icon: Icon(
                            _isMenuOpen ? Icons.close : Icons.menu, // Ikon berubah
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- KONTEN BAWAH HEADER (Berubah sesuai Menu) ---
                    Expanded(
                      child: _isMenuOpen 
                      ? _buildDropdownMenu(context) // Tampilan Menu (Gbr Tengah)
                      : _buildDefaultHeaderContent(), // Tampilan Normal (Gbr Kiri)
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. BODY MENU UTAMA (Card Horizontal) ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 10),
                
                // Tombol Peminjaman
                _buildWideCard(
                  icon: Icons.edit_document,
                  title: "Peminjaman",
                  iconColor: Colors.purpleAccent,
                  bgColor: const Color(0xFFF3E5F5), // Ungu pudar background icon
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FormPeminjamanScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Tombol Pengembalian
                _buildWideCard(
                  icon: Icons.assignment_return, // Ikon kotak balik
                  title: "Pengembalian",
                  iconColor: Colors.orange,
                  bgColor: const Color(0xFFFFF3E0), // Orange pudar background icon
                  onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Masuk ke Form Pengembalian"))
                     );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Tampilan Header Normal (Kiri) ---
  Widget _buildDefaultHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Mau pinjam apa hari ini?",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 15),
        // Tanggal Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 14),
              SizedBox(width: 8),
              Text(
                "Selasa, 18 November 2025",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        )
      ],
    );
  }

  // --- WIDGET: Tampilan Dropdown Menu (Tengah) ---
  Widget _buildDropdownMenu(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMenuItem(title: "Ubah Profil", onTap: () {}),
        _buildDivider(),
        _buildMenuItem(title: "History", onTap: () {}),
        _buildDivider(),
        _buildMenuItem(
          title: "Log Out", 
          onTap: () async {
            await AuthService().logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }
          }
        ),
      ],
    );
  }

  // Helper item menu text
  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.w600
              ),
            ),
            const Spacer(), // Biar text di kiri full
          ],
        ),
      ),
    );
  }

  // Helper garis putih tipis
  Widget _buildDivider() {
    return const Divider(color: Colors.white54, thickness: 0.5);
  }

  // --- WIDGET: Card Besar Horizontal (Peminjaman & Pengembalian) ---
  Widget _buildWideCard({
    required IconData icon, 
    required String title, 
    required Color iconColor, 
    required Color bgColor,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ]
        ),
        child: Row(
          children: [
            // Ikon Lingkaran Besar di Kiri
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: iconColor, // Warna lingkaran ungu/orange
                shape: BoxShape.circle,
                boxShadow: [
                   BoxShadow(
                    color: iconColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3)
                   )
                ]
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            
            // Teks Judul
            Text(
              title,
              style: const TextStyle(
                fontSize: 20, // Font besar sesuai figma
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}