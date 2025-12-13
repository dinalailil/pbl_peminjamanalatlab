import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'daftar_permintaan_screen.dart';
import 'history_peminjaman_screen.dart';
import 'detail_lab_admin_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

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

// --- BAGIAN INI WAJIB ADA AGAR lab['nama'] TIDAK MERAH ---
final List<Map<String, String>> _daftarLab = [
    {
      "nama": "LAB AI Lt. 7B", 
      "lokasi": "Lantai 7B"
    },
    {
      "nama": "Lab AI2 Lt. 7B", // Sesuai data firestore anda
      "lokasi": "Lantai 7T"
    },
    {
      "nama": "Lab Jaringan Lt. 7B", 
      "lokasi": "Lantai 7B"
    },
    {
      "nama": "Lab Multimedia Lt. 7B", 
      "lokasi": "Lantai 7B"
    },
  ];
  // ---------------------------------------------------------

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeBeranda(),
      _buildPermintaanTab(),
      _buildRiwayatTab(),
    ];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // =================================================================
  // 🟣 HOME TAB
  // =================================================================
  Widget _buildHomeBeranda() {
    final user = FirebaseAuth.instance.currentUser;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ====================== HEADER ==========================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColorStart, primaryColorEnd],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Row Profile + Logout ===
              Row(
                children: [
                  // Profile icon
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Nama Admin (Realtime)
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String namaUser = "Admin";

                        if (snapshot.hasData && snapshot.data!.exists) {
                          var data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          namaUser = data['nama'] ?? "Admin";
                        }

                        return Text(
                          "Hallo $namaUser",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),

                  // ⭐ Logout icon
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Text(
                "Selamat Datang di Labify",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 4),

              const Text(
                "Cek peminjaman hari ini!",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),

              const SizedBox(height: 20),

              // Tanggal pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white, size: 14),
                    SizedBox(width: 8),
                    Text(
                      "Selasa, 18 November 2025",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // JUDUL SECTION: Top 3 Borrowed
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Top 3 Most Borrowed Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      _topItems[index]['image']!,
                      height: 60,
                      width: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _topItems[index]['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    Text(
                      "Kode : ${_topItems[index]['code']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
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
              Icon(Icons.storage, color: Colors.black87),
              SizedBox(width: 10),
              Text(
                "Kelola Barang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

// --- LIST LAB (FIXED) ---
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _daftarLab.length, // Mengambil jumlah data dari variabel _daftarLab
              itemBuilder: (context, index) {
                final lab = _daftarLab[index]; // Mengambil data per item
                
                return GestureDetector(
                  onTap: () {
                    // NAVIGASI KE DETAIL LAB
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Mengirim nama lab ke halaman detail
                        builder: (context) => DetailLabAdminScreen(namaLab: lab['nama']!),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColorStart.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.computer, color: primaryColorStart),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lab['nama']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(lab['lokasi']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_note, color: primaryColorStart),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: PEMINJAMAN
  // ===========================================================================
  Widget _buildPermintaanTab() {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // ====================== HEADER UNGU ==========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColorStart, primaryColorEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Column(
              children: [
                Text(
                  "Daftar Permintaan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====================== LIST PERMINTAAN ==========================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPermintaanCard(
                  status: "Menunggu Persetujuan",
                  kode: "Alt001",
                  ruang: "Lab AI2 Lt.7T",
                  showStatus: true,
                ),
                const SizedBox(height: 15),

                _buildPermintaanCard(
                  status: "Menunggu Persetujuan",
                  kode: "Alt003",
                  ruang: "Lab AI Lt.7T",
                ),
                const SizedBox(height: 15),

                _buildPermintaanCard(
                  status: "Menunggu Persetujuan",
                  kode: "Alt001",
                  ruang: "Lab AI Lt.7T",
                ),
                const SizedBox(height: 15),

                _buildPermintaanCard(
                  status: "Menunggu Persetujuan",
                  kode: "Alt002",
                  ruang: "Lab AI Lt.7T",
                ),
                const SizedBox(height: 15),

                _buildPermintaanCard(
                  status: "Menunggu Persetujuan",
                  kode: "Alt002",
                  ruang: "Lab AI Lt.7T",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermintaanCard({
    required String status,
    required String kode,
    required String ruang,
    bool showStatus = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Jam Pasir
          const Icon(
            Icons.hourglass_empty_rounded,
            size: 45,
            color: Colors.black87,
          ),
          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Badge PROSES hanya di card pertama
                    if (showStatus)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Proses",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  "Kode : $kode",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  "Ruang : $ruang",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // Tombol Detail
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Detail",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: RIWAYAT
  // ===========================================================================
  Widget _buildRiwayatTab() {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // ====================== HEADER UNGU ==========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColorStart, primaryColorEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Riwayat Peminjaman",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // ===================== SEARCH BAR ======================
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====================== LIST RIWAYAT ==========================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildRiwayatCard("Aliando Setiawan"),
                const SizedBox(height: 15),

                _buildRiwayatCard("Dinarul"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CARD RIWAYAT
  // ===========================================================================
  Widget _buildRiwayatCard(String nama) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          GestureDetector(
            onTap: () {
              // TODO: Arahkan ke halaman detail
            },
            child: const Text(
              "Detail",
              style: TextStyle(
                fontSize: 15,
                decoration: TextDecoration.underline,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //===========================================================================
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
                  _buildNavItem(1, Icons.check_circle_rounded, Icons.check_circle_outlined), 
                  _buildNavItem(2, Icons.history_rounded, Icons.history_outlined),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // =============================
                  // ICON PERSON + OUTLINE CIRCLE
                  // =============================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black87,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =============================
                  // TEXT
                  // =============================
                  const Text(
                    "Apakah anda yakin\nkeluar dari aplikasi?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =============================
                  // BUTTON YA / TIDAK
                  // =============================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      // ===== BUTTON YA =====
                      GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await AuthService().logout();

                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Ya",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===== BUTTON TIDAK =====
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 110,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              "Tidak",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
