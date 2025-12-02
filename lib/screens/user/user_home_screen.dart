import 'dart:convert'; // WAJIB ADA: Untuk memproses Base64
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import '../../services/auth_service.dart';


import 'edit_profile_screen.dart'; 
import 'catalog_screen.dart';
import '../../screens/auth/login_screen.dart'; 

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isMenuOpen = false;
  String _tanggalHariIni = "";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        _tanggalHariIni = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // --- 1. HEADER DINAMIS ---
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: _isMenuOpen ? size.height * 0.45 : size.height * 0.35,
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
                    
                    // --- HEADER (AVATAR + NAMA) ---
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                      builder: (context, snapshot) {
                        String namaUser = "Loading...";
                        String? photoBase64; // Variabel Foto Base64

                        if (snapshot.hasData && snapshot.data!.exists) {
                          var data = snapshot.data!.data() as Map<String, dynamic>;
                          namaUser = data['nama'] ?? "User";
                          // Ambil data foto base64
                          if (data.containsKey('photo_base64')) {
                            photoBase64 = data['photo_base64'];
                          }
                        }

                        return Row(
                          children: [
                            // 1. AVATAR DINAMIS
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                // LOGIKA TAMPILAN FOTO BASE64:
                                image: (photoBase64 != null && photoBase64.isNotEmpty)
                                    ? DecorationImage(
                                        image: MemoryImage(base64Decode(photoBase64)), // Decode di sini
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              // Fallback Icon jika tidak ada foto
                              child: (photoBase64 == null || photoBase64.isEmpty)
                                  ? const Icon(Icons.person, color: Colors.grey, size: 30)
                                  : null,
                            ),
                            
                            const SizedBox(width: 15),
                            
                            // 2. NAMA USER
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$namaUser",
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_isMenuOpen)
                                     Text(
                                      _tanggalHariIni, 
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    )
                                ],
                              ),
                            ),

                            // 3. TOMBOL MENU
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isMenuOpen = !_isMenuOpen;
                                });
                              },
                              icon: Icon(_isMenuOpen ? Icons.close : Icons.menu, color: Colors.white, size: 30),
                            )
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- KONTEN BAWAH HEADER ---
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
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

          // --- 2. BODY MENU UTAMA ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 10),
                _buildWideCard(
                  icon: Icons.edit_document,
                  title: "Peminjaman",
                  iconColor: Colors.purpleAccent,
                  bgColor: const Color(0xFFF3E5F5),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CatalogScreen()));
                  },
                ),
                const SizedBox(height: 20),
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

  // --- HELPER WIDGETS ---

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
              Text(_tanggalHariIni.isEmpty ? "Memuat..." : _tanggalHariIni, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDropdownMenu(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMenuItem(
          title: "Ubah Profil", 
          onTap: () {
            setState(() => _isMenuOpen = false);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
          }
        ),
        _buildDivider(),
        _buildMenuItem(
          title: "Log Out", 
          onTap: () {
            _showLogoutDialog(context);
          }
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.grey[100], 
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                // 1. AVATAR USER (Ambil dari Firestore & Decode Base64)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
                  builder: (context, snapshot) {
                    String? photoBase64;
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      if (data.containsKey('photo_base64')) {
                        photoBase64 = data['photo_base64'];
                      }
                    }

                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                        ],
                        image: (photoBase64 != null && photoBase64.isNotEmpty)
                            ? DecorationImage(
                                image: MemoryImage(base64Decode(photoBase64)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (photoBase64 == null || photoBase64.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Color(0xFFEF4444)) 
                          : null,
                    );
                  },
                ),
                
                const SizedBox(height: 20),

                // 2. TEKS PERTANYAAN
                const Text(
                  "Apakah anda yakin\nkeluar dari aplikasi?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 30),

                // 3. TOMBOL YA / TIDAK
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext); 
                            showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
                            await Future.delayed(const Duration(milliseconds: 500));
                            
                            await AuthService().logout();
                            
                            if (context.mounted) {
                              Navigator.pop(context); 
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E78FF), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          child: const Text("Ya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),

                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E78FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          child: const Text("Tidak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

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

  Widget _buildDivider() {
    return const Divider(color: Colors.white54, thickness: 0.5);
  }

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