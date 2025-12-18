import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detail_permintaan_screen.dart';

class DaftarPermintaanScreen extends StatelessWidget {
  const DaftarPermintaanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          // ================== HEADER ==================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8E78FF),
                  Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Text(
              "Daftar Permintaan",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ================== LIST FIRESTORE ==================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('peminjaman')
                  .where("status", whereIn: ["diajukan", "disetujui"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada permintaan peminjaman",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final data = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final pem = data[index];
                    final pemData = pem.data() as Map<String, dynamic>;

                    final status = pemData['status'] ?? 'diajukan';

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPermintaanScreen(data: pem),
                              ),
                            );
                          },
                          child: _buildPermintaanCard(
                            status: status,
                            kode: pemData['kode_barang'] ?? "-",
                            namalab: pemData[''] ?? "-",
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ================== BOTTOM BAR ==================
          Container(
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF764BA2),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.home, color: Colors.white, size: 30),
                Icon(Icons.person, color: Colors.white, size: 30),
                Icon(Icons.history, color: Colors.white, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== STATUS TEXT ==================
  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'diajukan':
        return 'Menunggu Persetujuan';
      case 'disetujui':
        return 'Menunggu Persetujuan';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return 'Menunggu Persetujuan';
    }
  }

  // ================== CARD ==================
  Widget _buildPermintaanCard({
    required String status,
    required String kode,
    required String namalab,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.compare_arrows_sharp,
            color: Color(0xFF764BA2),
            size: 36,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getStatusDisplayText(status),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(status), // ✔ hanya tampil jika diajukan
                  ],
                ),

                const SizedBox(height: 6),
                Text("Kode : $kode", style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  "Ruang : $namalab",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const Text(
            "Detail",
            style: TextStyle(
              fontSize: 12,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================== BADGE ==================
  Widget _buildStatusBadge(String status) {
    // ✔ Badge HANYA muncul saat status = disetujui
    if (status != 'disetujui') {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        "Proses",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}