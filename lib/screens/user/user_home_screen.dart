import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../services/auth_service.dart';

import 'history_screen.dart';
import 'help_screen.dart';
import 'notification_screen.dart';
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

  // Warna Tema (Ungu Halus)
  final Color primaryColorStart = const Color(0xFF8E78FF);
  final Color primaryColorEnd = const Color(0xFF764BA2);
  final Color scaffoldBgColor = const Color(0xFFF8F9FA);

  // Data Dummy Top Borrowed
  final List<Map<String, String>> _topItems = [
    {"name": "Proyektor Epson", "code": "Alt001", "image":"https://tse3.mm.bing.net/th/id/OIP.OeOqeXR8-0NM-913ZQOQuQHaEJ?pid=Api&P=0&h=180"}, // Ganti dengan aset lokal jika ada
    {"name": "Laptop Lenovo", "code": "Alt002", "image": "https://e7.pngegg.com/pngimages/552/936/png-clipart-laptop-lenovo-ideapad-720-lenovo-ideapad-710s-plus-laptop-electronics-gadget.png"},
    {"name": "Mouse Wireless", "code": "Alt003", "image": "https://www.nicepng.com/png/detail/74-746964_hp-z5000-dark-ash-silver-wireless-mouse.png"},
  ];

  // Data Dummy Lab
  final List<String> _labList = [
    "Lab AI Lt. 7B",
    "Lab Jaringan Lt. 7B",
    "Lab Multimedia Lt. 7B",
    "Lab AI2 Lt. 7T",
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
      _buildNotificationTab(), // Tab Tengah jadi Notifikasi/Transaksi
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ===========================================================================
  // TAB 1: BERANDA (REVISI SESUAI GAMBAR)
  // ===========================================================================
  Widget _buildHomeBeranda() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER UNGU + SEARCH BAR
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                // Background Gradient
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
                ),
                
                // Konten Header (Teks Sapaan)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                        builder: (context, snapshot) {
                          String nama = "User";
                          if (snapshot.hasData && snapshot.data!.exists) {
                            nama = snapshot.data!['nama'] ?? "User";
                          }
                          return Text(
                            "Halo $nama",
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Selamat Datang di Labify\nMau pinjam apa hari ini?",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      // Tanggal Pill Kecil
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()), 
                                 style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
 
                // Search Bar Melayang

                  Positioned(
                  bottom: 0,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      // Langsung pindah ke halaman Katalog saat search bar diklik
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const CatalogScreen())
                      );
                    },
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
                          Text(
                            "Cari alat atau laboratorium...", 
                            style: TextStyle(color: Colors.grey[400], fontSize: 16)
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // JUDUL SECTION: Top 3 Borrowed
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Top 3 Most Borrowed Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          const SizedBox(height: 15),

          // LIST HORIZONTAL BARANG
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _topItems.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(_topItems[index]['image']!, height: 60, width: 80, fit: BoxFit.contain, errorBuilder: (c,e,s)=>const Icon(Icons.image, size: 50, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(_topItems[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 2),
                      Text("Kode : ${_topItems[index]['code']}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // JUDUL SECTION: Laboratorium (Dengan Background Biru Muda)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFCBE6FF), // Biru Muda
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.list_alt, color: Colors.black87),
                SizedBox(width: 10),
                Text("Laboratorium", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // LIST LABORATORIUM (Vertical)
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _labList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle, size: 12, color: Colors.grey), // Dot abu-abu
                        const SizedBox(width: 15),
                        Text(_labList[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black87),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: NOTIFIKASI (Tampilan List Simple)
  // ===========================================================================
  Widget _buildNotificationTab() {
    return Scaffold( // Pakai Scaffold lagi biar background header ungu full
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8E78FF), // Ungu
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, // Header tinggi
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Item Notifikasi 1
          _buildNotifItem("Kode Alt001", "01 Sept 2025 - 02 Okt 2025", "Disetujui", Colors.green),
          const SizedBox(height: 15),
          // Item Notifikasi 2
          _buildNotifItem("Kode Alt005", "10 Sept 2025 - 12 Sept 2025", "Ditolak", Colors.red),
          const SizedBox(height: 15),
          // Item Notifikasi 3 (Pending)
          _buildNotifItem("Kode Alt008", "15 Sept 2025 - 16 Sept 2025", "Proses", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildNotifItem(String title, String date, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          // Gambar Barang (Placeholder)
          Container(
            width: 60, height: 40,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.inventory_2, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text("Jumlah: 1", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text("Status", style: TextStyle(color: Colors.white, fontSize: 10)),
                Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }


// ===========================================================================
  // TAB 3: PROFIL (HEADER FULL BLOCK + JUDUL TENGAH)
  // ===========================================================================
  Widget _buildProfileTab() {
     return SingleChildScrollView(
        child: Column(
          children: [
            // HEADER STACK
            SizedBox(
              height: 240, 
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center, // KUNCI: Align Center agar judul di tengah
                children: [
                  // 1. Background Gradient Full Block (dengan border radius bawah)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 180, // Tinggi area ungu
                    child: Container(
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
                      // Child SafeArea untuk Judul
                      child: const SafeArea(
                        child: Column(
                          children: [
                            SizedBox(height: 20), // Jarak dari atas (status bar)
                            Text(
                              "Profil Saya",
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Avatar User Overlap
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
                          width: 120, height: 120,
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

            // Nama & Email (Tetap sama)
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

            // Menu Profil (Tetap sama)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildProfileMenuItem(icon: Icons.edit, text: "Ubah Profil", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()))),
                  _buildProfileMenuItem(
  icon: Icons.history, 
  text: "Riwayat Transaksi", 
  onTap: () {
     Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
  }
),
                  _buildProfileMenuItem(
  icon: Icons.help_outline, 
  text: "Bantuan", 
  onTap: () {
     Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
  }
),
                  
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

  Widget _buildProfileMenuItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.black87),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
  

 // FUNGSI DIALOG LOGOUT CUSTOM (Avatar + Rounded Button)
  void _showLogoutDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      barrierDismissible: false, // User gak bisa tutup paksa dengan klik luar
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.grey[100], 
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tinggi dialog sesuai isi
              children: [
                // 1. AVATAR USER (Ambil dari Firestore & Decode Base64)
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
                  builder: (context, snapshot) {
                    String? photoBase64;
                    
                    // Ambil data photo_base64
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
                        // LOGIKA GAMBAR BASE64:
                        image: (photoBase64 != null && photoBase64.isNotEmpty)
                            ? DecorationImage(
                                image: MemoryImage(base64Decode(photoBase64)), // Decode di sini
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      // Jika tidak ada foto, tampilkan icon default Merah-Pink
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
                    // TOMBOL YA (LOGOUT)
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext); // Tutup dialog konfirmasi
                            
                            // Tampilkan Loading sebentar
                            showDialog(
                              context: context, 
                              barrierDismissible: false, 
                              builder: (c) => const Center(child: CircularProgressIndicator())
                            );
                            
                            await Future.delayed(const Duration(milliseconds: 500)); // Efek visual
                            await AuthService().logout(); // Logout Firebase
                            
                            if (context.mounted) {
                              Navigator.pop(context); // Tutup loading
                              // Pindah ke Login Screen
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E78FF), // Warna Ungu Tema
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          child: const Text("Ya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),

                    // TOMBOL TIDAK (BATAL)
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E78FF), // Warna Ungu Tema (Sama)
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

// ===========================================================================
  // BOTTOM NAVIGATION BAR (CUSTOM - PIPIH & PRESISI TENGAH)
  // ===========================================================================
  Widget _buildBottomNavBar() {
    return Container(
      height: 80, // Tinggi area aman bawah
      decoration: const BoxDecoration(
        color: Colors.transparent, 
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20, 
            right: 20, 
            bottom: 20, // Melayang dari bawah
            child: Container(
              height: 65, // Tinggi Bar "Pipih"
              decoration: BoxDecoration(
                // Gradient Ungu
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(35), // Sudut bulat penuh (Pil)
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF764BA2).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
                  _buildNavItem(1, Icons.notifications_rounded, Icons.notifications_outlined), 
                  _buildNavItem(2, Icons.person_rounded, Icons.person_outline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk Item Navigasi Custom
  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          // Jika aktif: Background Putih. Jika tidak: Transparan
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle, // Bentuk lingkaran indikator
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon, // Ganti icon isi/garis
          // Jika aktif: Icon Ungu. Jika tidak: Icon Putih
          color: isSelected ? const Color(0xFF764BA2) : Colors.white70,
          size: 28, // Ukuran ikon pas
        ),
      ),
    );
  }
}