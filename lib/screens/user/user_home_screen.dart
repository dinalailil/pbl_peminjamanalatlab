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
import 'search_screen.dart';
import '../../screens/auth/login_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  final Color primaryColorStart = const Color(0xFF8E78FF);
  final Color primaryColorEnd = const Color(0xFF764BA2);
  final Color scaffoldBgColor = const Color(0xFFF8F9FA);

  // -----------------------------
  // 🔥 TOP ITEMS Dummy (tetap sama)
  // -----------------------------
  final List<Map<String, String>> _topItems = [
    {
      "name": "Proyektor Epson",
      "code": "Alt001",
      "image":
          "https://tse3.mm.bing.net/th/id/OIP.OeOqeXR8-0NM-913ZQOQuQHaEJ?pid=Api"
    },
    {
      "name": "Laptop Lenovo",
      "code": "Alt002",
      "image":
          "https://e7.pngegg.com/pngimages/552/936/png-clipart-laptop-lenovo-ideapad-720-lenovo-ideapad-710s-plus-laptop-electronics-gadget.png"
    },
    {
      "name": "Mouse Wireless",
      "code": "Alt003",
      "image":
          "https://www.nicepng.com/png/detail/74-746964_hp-z5000-dark-ash-silver-wireless-mouse.png"
    }
  ];

  // -----------------------------
  // 🔥 STREAM LAB — PENGGANTI DUMMY
  // -----------------------------
  Stream<QuerySnapshot> getLabStream() {
    return FirebaseFirestore.instance.collection('laboratorium').snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeBeranda(),
      _buildNotificationTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }


Future<String?> pilihLaboratorium(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Pilih Laboratorium",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("laboratorium")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var labs = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: labs.length,
                itemBuilder: (context, index) {
                  var data = labs[index].data() as Map<String, dynamic>;

                  String namaLab = data["nama"] ?? "Tanpa Nama";

                  return ListTile(
                    title: Text(namaLab),
                    subtitle: Text("Lantai: ${data['lantai'] ?? '-'}"),
                    onTap: () {
                     Navigator.pop(context, data["nama"]);

                    },
                  );
                },
              );
            },
          ),
        ),
      );
    },
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
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String nama = "User";
                          if (snapshot.hasData && snapshot.data!.exists) {
                            nama = snapshot.data!['nama'] ?? "User";
                          }
                          return Text(
                            "Halo $nama",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Selamat Datang di Labify",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      // Tanggal Pill Kecil
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                    .format(DateTime.now()),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
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
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SearchScreen()),
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
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 16),
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

          // TOP 3 ITEMS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Top 3 Most Borrowed Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 15),
          const SizedBox(height: 15),

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
                          blurRadius: 5)
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
                            fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      Text(
                        "Kode : ${_topItems[index]['code']}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // TITLE "LABORATORIUM"
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFCBE6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.list_alt, color: Colors.black87),
                SizedBox(width: 10),
                Text("Laboratorium",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // =======================
          //  LIST LAB FROM FIRESTORE
          // =======================
          StreamBuilder<QuerySnapshot>(
            stream: getLabStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final labs = snapshot.data!.docs;

              if (labs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Belum ada data lab", style: TextStyle(fontSize: 16)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: labs.length,
                itemBuilder: (context, index) {
                  final lab = labs[index].data() as Map<String, dynamic>;
                  final namaLab = lab['nama'] ?? "-";

                  return InkWell(
                    key: index == 0 ? const Key('item_alat_0') : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CatalogScreen(
                            labName: namaLab, // 🔥 dikirim ke katalog
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding:
                          const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 5)
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.circle, size: 12, color: Colors.grey),
                              const SizedBox(width: 15),
                              Text(namaLab,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.black87),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ====================================================================
  // TAB NOTIFIKASI
  // ====================================================================
  Widget _buildNotificationTab() {
  String uid = FirebaseAuth.instance.currentUser!.uid;

  return Column(
    children: [
      // HEADER UNGU
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors:[Color(0xFF8E78FF), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: const Center(
          child: Text(
            "Notifikasi",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),

      // LIST NOTIF (Expand harus di luar Column)
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("peminjaman")
              .where("user_uid", isEqualTo: uid)
              .orderBy("created_at", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var data = snapshot.data!.docs;

            if (data.isEmpty) {
              return const Center(
                child: Text(
                  "Tidak ada notifikasi",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: data.length,
              itemBuilder: (context, index) {
                var item = data[index];
                var map = item.data() as Map<String, dynamic>;
                print("DEBUG GAMBAR = ${map['gambar']}");
print("TIPE GAMBAR = ${map['gambar']?.runtimeType}");


                String status = map["status"] ?? "-";
                String statusText = "";

               // STATUS TEXT
if (status == "disetujui") {
  statusText = "Proses Disetujui";
} else if (status == "dipinjam") {
  statusText = "Proses Peminjaman";
} else if (status == "ditolak") {                  
  statusText = "Pengajuan Ditolak";
} else {
  return const SizedBox.shrink();
}


                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // GAMBAR ALAT
                   ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.network(
    map["gambar"],
    width: 70,
    height: 70,
    fit: BoxFit.contain, // → ubah di sini
  ),
),


                      const SizedBox(width: 15),

                      // INFO ALAT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kode ${map['kode_barang']}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${_format(map['tgl_pinjam'])} - ${_format(map['tgl_kembali'])}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              "Jumlah: ${map['jumlah_pinjam']}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // STATUS
                     // STATUS BADGE
Container(
  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
  decoration: BoxDecoration(
    color: status == "disetujui"
        ? Colors.greenAccent.shade100
        : status == "dipinjam"
            ? Colors.blueAccent.shade100
            : Colors.redAccent.shade100,               //  ditolak
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    statusText,
    style: TextStyle(
      color: status == "disetujui"
          ? Colors.green
          : status == "dipinjam"
              ? Colors.blue
              : Colors.red,                            //  ditolak
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  ),
)

                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

// FORMAT TANGGAL
String _format(Timestamp t) {
  DateTime d = t.toDate();
  return "${d.day} ${_bulan(d.month)} ${d.year}";
}

String _bulan(int m) {
  const b = [
    "Jan","Feb","Mar","Apr","Mei","Jun",
    "Jul","Agu","Sep","Okt","Nov","Des"
  ];
  return b[m - 1];
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
                      key: const Key('btn_logout'),
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
    key: index == 2 ? const Key('nav_profil') : null,
    onTap: () {
      // === Navigasi disesuaikan ===
if (index == 1) {
  _onItemTapped(1);   // pindah tab, bukan buka halaman
  return;
}


      // Jika Home atau Profile
      _onItemTapped(index);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSelected ? activeIcon : inactiveIcon,
        color: isSelected ? const Color(0xFF764BA2) : Colors.white70,
        size: 28,
      ),
    ),
  );
}

}