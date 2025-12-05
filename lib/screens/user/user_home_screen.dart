import 'dart:convert'; // WAJIB: Untuk decode foto profil Base64
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import '../../services/auth_service.dart';

import 'edit_profile_screen.dart'; 
import 'catalog_screen.dart';
import 'pengembalian_screen.dart';
import '../../screens/auth/login_screen.dart'; 

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  // Warna Tema
  final Color primaryColorStart = const Color(0xFF6C63FF); 
  final Color primaryColorEnd = const Color(0xFF4834DF);   
  final Color scaffoldBgColor = const Color(0xFFF8F9FA);   

  // Data Dummy Lab
  final List<Map<String, String>> _daftarLab = [
    {"nama": "Lab Komputer Dasar", "lokasi": "Gedung AD Lt. 2", "status": "Buka"},
    {"nama": "Lab Jaringan", "lokasi": "Gedung AO Lt. 3", "status": "Buka"},
    {"nama": "Lab Multimedia", "lokasi": "Gedung AE Lt. 1", "status": "Penuh"},
    {"nama": "Lab IoT & Robotik", "lokasi": "Gedung AL Lt. 2", "status": "Tutup"},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeBeranda(),  
      _buildTransaksiTab(), 
      _buildProfileTab(),   
    ];

    return Scaffold(
      backgroundColor: scaffoldBgColor, 
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ===========================================================================
  // TAB 1: BERANDA (DENGAN ILUSTRASI)
  // ===========================================================================
  Widget _buildHomeBeranda() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- STACK HEADER ---
          SizedBox(
            height: 260, // Sedikit lebih tinggi untuk muat gambar
            child: Stack(
              children: [
                // 1. Background Gradient + ILUSTRASI
                Container(
                  height: 220, 
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColorStart, primaryColorEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  // --- BAGIAN INI MENAMPILKAN GAMBAR HANYA DI BERANDA ---
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Opacity(
                            opacity: 0.3, // Transparan agar tulisan terbaca
                            child: Image.asset(
                              'images/ilustration.png', 
                              fit: BoxFit.cover,
                              height: 180, 
                              width: double.infinity, 
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // -------------------------------------------------------
                ),

                // 2. Konten Header
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.grain, color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          const Text(
                            "Labify",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(Icons.mail_outline, color: Colors.white)),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                ),

                // 3. Search Bar Melayang
                Positioned(
                  bottom: 0,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: primaryColorStart, size: 26),
                        const SizedBox(width: 15),
                        Text("Cari alat atau laboratorium...", style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- GRID MENU ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 15,
              children: [
                _buildGridMenuItem(Icons.add_shopping_cart, "Pinjam Alat", primaryColorStart, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CatalogScreen()));
                }),
                _buildGridMenuItem(Icons.assignment_return, "Kembalikan", Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PengembalianScreen()));
                }),
                _buildGridMenuItem(Icons.list_alt, "Daftar Lab", Colors.blue, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur List Lab Lengkap segera hadir")));
                }),
                _buildGridMenuItem(Icons.history, "Riwayat", Colors.purple, () {}),
                
                _buildGridMenuItem(Icons.inventory_2_outlined, "Stok Alat", Colors.teal, () {}),
                _buildGridMenuItem(Icons.rule, "Tata Tertib", Colors.redAccent, () {}),
                _buildGridMenuItem(Icons.map_outlined, "Peta Lab", Colors.indigo, () {}),
                _buildGridMenuItem(Icons.help_outline, "Bantuan", Colors.grey, () {}),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- SECTION BAWAH ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: primaryColorStart),
                    const SizedBox(width: 8),
                    const Text("Informasi & Ketersediaan Lab", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,5))],
                    image: const DecorationImage(
                      image: AssetImage('images/pol.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                 const SizedBox(height: 20),
                 ..._daftarLab.map((lab) => _buildLabCardLite(lab)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: TRANSAKSI (POLOS TANPA GAMBAR)
  // ===========================================================================
  Widget _buildTransaksiTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- HEADER LABIFY ---
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColorStart, primaryColorEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.grain, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        const Text("Labify", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.mail_outline, color: Colors.white)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Transaksi", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("Kelola peminjaman barang anda", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),

                _buildBigMenuCard(
                  title: "Peminjaman Baru",
                  subtitle: "Ajukan peminjaman alat",
                  icon: Icons.add_shopping_cart,
                  color: primaryColorStart,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CatalogScreen())),
                ),
                
                const SizedBox(height: 20),

                _buildBigMenuCard(
                  title: "Pengembalian",
                  subtitle: "Kembalikan barang",
                  icon: Icons.assignment_return_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PengembalianScreen())),
                ),
                const SizedBox(height: 30), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: PROFIL (POLOS TANPA GAMBAR)
  // ===========================================================================
  Widget _buildProfileTab() {
     return SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER STACK ---
            SizedBox(
              height: 240, 
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 180, 
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColorStart, primaryColorEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.grain, color: Color.fromARGB(255, 255, 255, 255), size: 28),
                                    const SizedBox(width: 10),
                                    const Text("Labify", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(onPressed: () {}, icon: const Icon(Icons.mail_outline, color: Colors.white)),
                                    IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0, 
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                      builder: (context, snapshot) {
                        String? photoBase64;
                        if (snapshot.hasData && snapshot.data!.exists) {
                          var data = snapshot.data!.data() as Map<String, dynamic>;
                          if (data.containsKey('photo_base64')) photoBase64 = data['photo_base64'];
                        }
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                            image: (photoBase64 != null && photoBase64.isNotEmpty)
                                ? DecorationImage(image: MemoryImage(base64Decode(photoBase64)), fit: BoxFit.cover)
                                : null,
                          ),
                          child: (photoBase64 == null || photoBase64.isEmpty)
                              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
              builder: (context, snapshot) {
                String nama = "Loading...";
                String email = user?.email ?? "";
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  nama = data['nama'] ?? "User";
                }
                return Column(
                  children: [
                    Text(nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(email, style: const TextStyle(color: Colors.grey)),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildProfileMenuItem(icon: Icons.edit, text: "Ubah Profil", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()))),
                  _buildProfileMenuItem(icon: Icons.history, text: "Riwayat Transaksi", onTap: () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur History segera hadir!")));
                  }),
                  _buildProfileMenuItem(icon: Icons.help_outline, text: "Bantuan", onTap: () {}),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text("Keluar Aplikasi", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildGridMenuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Widget _buildLabCardLite(Map<String, String> lab) {
    bool isOpen = lab['status'] == "Buka";
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(10),
         boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
      ),
      child: Row(
        children: [
          Icon(Icons.domain, color: isOpen ? primaryColorStart : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(lab['nama']!, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(lab['status']!, style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBigMenuCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,5))]
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 32)),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(onTap: onTap, leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.black87, size: 20)), title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), contentPadding: EdgeInsets.zero);
  }

  void _showLogoutDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(context: context, barrierDismissible: false, builder: (context) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
      FutureBuilder<DocumentSnapshot>(future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(), builder: (context, snapshot) { String? photoBase64; if (snapshot.hasData && snapshot.data!.exists) { var data = snapshot.data!.data() as Map<String, dynamic>; if (data.containsKey('photo_base64')) photoBase64 = data['photo_base64']; } return Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)], image: (photoBase64 != null && photoBase64.isNotEmpty) ? DecorationImage(image: MemoryImage(base64Decode(photoBase64)), fit: BoxFit.cover) : null), child: (photoBase64 == null || photoBase64.isEmpty) ? const Icon(Icons.person, size: 50, color: Color(0xFFEF4444)) : null); }),
      const SizedBox(height: 20), const Text("Apakah anda yakin\nkeluar dari aplikasi?", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
      Row(children: [Expanded(child: ElevatedButton(onPressed: () async { Navigator.pop(context); await AuthService().logout(); if(context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E78FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), child: const Text("Ya", style: TextStyle(color: Colors.white)))), const SizedBox(width: 15), Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E78FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), child: const Text("Tidak", style: TextStyle(color: Colors.white))))])
    ]))));
  }


  // ===========================================================================
  // BOTTOM NAVIGATION BAR
  // ===========================================================================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_rounded), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColorStart, 
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}