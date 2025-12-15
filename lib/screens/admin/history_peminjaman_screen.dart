import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_peminjaman_detail_screen.dart';

class HistoryPeminjamanScreen extends StatefulWidget {
  const HistoryPeminjamanScreen({super.key});

  @override
  State<HistoryPeminjamanScreen> createState() =>
      _HistoryPeminjamanScreenState();
}

class _HistoryPeminjamanScreenState extends State<HistoryPeminjamanScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          // ================== HEADER + SEARCH ==================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
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
            child: Column(
              children: [
                const Text(
                  "Riwayat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // ================== SEARCH BAR ==================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ================== LIST FIRESTORE ==================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("peminjaman")
                  .where("status", isEqualTo: "selesai")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada riwayat peminjaman selesai.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                // ================== GROUPING BY USER ==================
                Map<String, List<DocumentSnapshot>> groupedUser = {};

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nama =
                      data["nama_peminjam"] ?? data["nama_user"] ?? "-";

                  // FILTER SEARCH
                  if (!nama.toLowerCase().contains(searchQuery)) continue;

                  groupedUser.putIfAbsent(nama, () => []);
                  groupedUser[nama]!.add(doc);
                }

                if (groupedUser.isEmpty) {
                  return const Center(
                    child: Text(
                      "Data tidak ditemukan.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final namaUserList = groupedUser.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: namaUserList.length,
                  itemBuilder: (context, index) {
                    final namaUser = namaUserList[index];
                    final daftarRiwayat = groupedUser[namaUser]!;

                    return Column(
                      children: [
                        _buildPeminjamanCard(
                          nama: namaUser,
                          onDetailTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HistoryPeminjamanDetailScreen(
                                  namaUser: namaUser,
                                  daftarRiwayat: daftarRiwayat,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================== CARD ==================
  Widget _buildPeminjamanCard({
    required String nama,
    required VoidCallback onDetailTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nama,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onDetailTap,
            child: const Text(
              "Detail",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}