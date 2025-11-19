import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // --- 1. HEADER GRADIENT (Admin Style: Red - Purple) ---
          Container(
            height: size.height * 0.35,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF512F), // Orange Kemerahan (Energi/Alert)
                  Color(0xFFDD2476), // Deep Pink/Red (Otoritas)
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Avatar Admin (Border Emas/Kuning dikit biar beda)
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.amberAccent, width: 2),
                                ),
                                child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              
                              // Nama Admin Dinamis
                              Expanded(
                                child: StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user?.uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    String namaAdmin = "Admin";
                                    if (snapshot.hasData && snapshot.data!.exists) {
                                      var data = snapshot.data!.data() as Map<String, dynamic>;
                                      namaAdmin = data['nama'] ?? "Admin"; 
                                    }
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Halo, $namaAdmin",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Text(
                                          "Admin Lab", 
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        IconButton(
                          onPressed: () async {
                            await AuthService().logout();
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                        )
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Statistik Singkat (Dashboard Admin biasanya butuh ini)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(count: "5", label: "Pending"),
                          _StatItem(count: "12", label: "Dipinjam"),
                          _StatItem(count: "8", label: "Selesai"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. MENU GRID ADMIN ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Panel Kontrol",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        // 1. KONFIRMASI PEMINJAMAN (Penting)
                        _buildMenuCard(
                          icon: Icons.playlist_add_check, 
                          title: "Konfirmasi\nPeminjaman",
                          color: Colors.orange, // Orange = Butuh Tindakan
                          onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Buka List Request Peminjaman"))
                             );
                          },
                        ),
                        
                        // 2. KONFIRMASI PENGEMBALIAN
                        _buildMenuCard(
                          icon: Icons.assignment_turned_in,
                          title: "Konfirmasi\nPengembalian",
                          color: Colors.green, // Hijau = Selesai/Verifikasi
                          onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Buka List Pengembalian Barang"))
                             );
                          },
                        ),
                        
                        // 3. HISTORY SEMUA
                        _buildMenuCard(
                          icon: Icons.history_edu, // Icon History yang lebih formal
                          title: "Semua\nRiwayat",
                          color: Colors.blueGrey,
                          onTap: () {},
                        ),
                        
                        // 4. PROFIL ADMIN / PENGATURAN
                        _buildMenuCard(
                          icon: Icons.manage_accounts,
                          title: "Profil\nAdmin",
                          color: Colors.purple,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Kartu Menu
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center, // Agar teks 2 baris rapi di tengah
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Helper Kecil untuk Statistik di Header
class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 18
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70, 
            fontSize: 12
          ),
        ),
      ],
    );
  }
}