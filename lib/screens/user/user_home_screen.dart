import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Pastikan sudah: flutter pub add intl
import 'package:intl/date_symbol_data_local.dart'; 
import '../../services/auth_service.dart';
<<<<<<< HEAD
import 'form_peminjaman_screen.dart';
import 'edit_profile_screen.dart'; // Pastikan file ini ada (meski fiturnya diskip)
=======
import 'catalog_screen.dart';
>>>>>>> origin/jak

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  // State menu terbuka/tutup
  bool _isMenuOpen = false;
  
  // Variabel tanggal hari ini
  String _tanggalHariIni = "";

  @override
  void initState() {
    super.initState();
    // Inisialisasi Format Tanggal Bahasa Indonesia
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        // Format: "Selasa, 25 November 2025"
        _tanggalHariIni = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu sangat muda
      body: Column(
        children: [
          // --- 1. HEADER DINAMIS (UNGU-MERAH) ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            // Tinggi header menyesuaikan menu buka/tutup
            height: _isMenuOpen ? size.height * 0.55 : size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
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
                    // --- BARIS ATAS: AVATAR + NAMA + MENU ---
                    Row(
                      children: [
                        // Avatar Lingkaran
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
                        
                        // Nama User dari Firestore
                        Expanded(
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
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
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Tampilkan tanggal kecil jika menu terbuka
                                  if (_isMenuOpen)
                                     Text(
                                      _tanggalHariIni, 
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    )
                                ],
                              );
                            },
                          ),
                        ),

                        // Tombol Burger Menu
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isMenuOpen = !_isMenuOpen;
                            });
                          },
                          icon: Icon(_isMenuOpen ? Icons.close : Icons.menu, color: Colors.white, size: 30),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- KONTEN BAWAH HEADER (Scrollable agar tidak error overflow) ---
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(), // Scroll otomatis, user ga usah scroll
                        child: _isMenuOpen 
                          ? _buildDropdownMenu(context) 
                          : _buildDefaultHeaderContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. BODY MENU UTAMA (KARTU PUTIH) ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 10),
                
                // KARTU PEMINJAMAN
                _buildWideCard(
                  icon: Icons.edit_document,
                  title: "Peminjaman",
                  iconColor: Colors.purpleAccent,
                  bgColor: const Color(0xFFF3E5F5),
                  onTap: () {
<<<<<<< HEAD
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FormPeminjamanScreen()));
=======
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CatalogScreen()),
                    );
>>>>>>> origin/jak
                  },
                ),
                
                const SizedBox(height: 20),
                
                // KARTU PENGEMBALIAN
                _buildWideCard(
                  icon: Icons.assignment_return,
                  title: "Pengembalian",
                  iconColor: Colors.orange,
                  bgColor: const Color(0xFFFFF3E0),
                  onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masuk ke Form Pengembalian")));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tampilan Normal (Tanggal Besar)
  Widget _buildDefaultHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Mau pinjam apa hari ini?", style: TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 14),
              const SizedBox(width: 8),
              Text(
                _tanggalHariIni.isEmpty ? "Memuat..." : _tanggalHariIni, // Tanggal Realtime
                style: const TextStyle(color: Colors.white, fontSize: 12)
              ),
            ],
          ),
        )
      ],
    );
  }

  // Widget Menu Dropdown (Ubah Profil, History, Logout)
  Widget _buildDropdownMenu(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. Ubah Profil
        _buildMenuItem(
          title: "Ubah Profil", 
          onTap: () {
            // Tutup menu
            setState(() => _isMenuOpen = false);
            // Pindah halaman (Pastikan edit_profile_screen.dart ada, meski kosong isinya gpp)
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          }
        ),
        _buildDivider(),
        
        // 2. History
        _buildMenuItem(
          title: "History", 
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur History segera hadir!")));
          }
        ),
        _buildDivider(),
        
        // 3. Log Out (DENGAN KONFIRMASI)
        _buildMenuItem(
          title: "Log Out", 
          onTap: () {
            // Panggil Dialog Konfirmasi Logout
            _showLogoutDialog(context);
          }
        ),
      ],
    );
  }

  // FUNGSI DIALOG KONFIRMASI LOGOUT
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Batal
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                await AuthService().logout(); // Logout Firebase
                if (context.mounted) {
                  // Kembali ke Login & Hapus history navigasi
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Helper Widget Item Menu Teks
  Widget _buildMenuItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Helper Garis Putih Tipis
  Widget _buildDivider() {
    return const Divider(color: Colors.white54, thickness: 0.5);
  }

  // Helper Widget Kartu Besar (Peminjaman/Pengembalian)
  Widget _buildWideCard({required IconData icon, required String title, required Color iconColor, required Color bgColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: iconColor, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: iconColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3))]
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}