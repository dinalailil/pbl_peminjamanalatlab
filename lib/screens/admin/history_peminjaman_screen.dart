import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'detail_peminjaman_screen.dart';
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_peminjaman_detail_screen.dart';
>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1

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
      backgroundColor: const Color(0xFFFFD2D2),
      body: Column(
        children: [
<<<<<<< HEAD
          // HEADER
=======
          // ================== HEADER + SEARCH ==================
>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
<<<<<<< HEAD
=======
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
<<<<<<< HEAD
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // SEARCH BAR
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, size: 20, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            "Search",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  ],
=======
            child: Column(
              children: [
                const Text(
                  "Riwayat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1
                ),

                const SizedBox(height: 20),

                // ================== SEARCH BAR DI HEADER ==================
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

<<<<<<< HEAD
          // LIST NAMA PEMINJAM
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _peminjamCard(
                    context,
                    nama: "Aliando Setiawan",
                  ),
                ],
              ),
=======
          const SizedBox(height: 10),

          // ================== LIST FIRESTORE ==================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("peminjaman")
                  .where("status", isEqualTo: "selesai")
                  .snapshots(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Jika Firestore kosong (belum ada data selesai)
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada riwayat peminjaman selesai.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                // Ambil seluruh data dari Firestore
                List<DocumentSnapshot> data = snapshot.data!.docs;

                // ================== FILTER LOCAL (SEARCH) ==================
                List<DocumentSnapshot> filteredData = data.where((doc) {
                  final pem = doc.data() as Map<String, dynamic>;
                  final nama =
                      (pem["nama_peminjam"] ?? pem["nama_user"] ?? "")
                          .toString()
                          .toLowerCase();
                  return nama.contains(searchQuery);
                }).toList();

                // Jika hasil filter kosong, tampilkan pesan khusus search
                if (filteredData.isEmpty) {
                  return const Center(
                    child: Text(
                      "Data tidak ditemukan.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final item = filteredData[index];
                    final pem = item.data() as Map<String, dynamic>;

                    String nama =
                        pem["nama_peminjam"] ?? pem["nama_user"] ?? "-";

                    return Column(
                      children: [
                        _buildPeminjamanCard(
                          nama: nama,
                          onDetailTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HistoryPeminjamanDetailScreen(data: item),
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
>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _peminjamCard(BuildContext context, {required String nama}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPeminjamanScreen(
              nama: nama,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage("assets/profile.png"),
            ),
            const SizedBox(width: 15),
            Text(
              nama,
              style: const TextStyle(
                fontSize: 16,
=======
  // ================== CARD COMPONENT ==================
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
>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1
                fontWeight: FontWeight.w600,
              ),
            ),
<<<<<<< HEAD
            const Spacer(),
            const Text(
              "Lihat Detail",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
=======
          ),
        ],
>>>>>>> 37c1905bf49a11ba884aae70a3765c6cc688aff1
      ),
    );
  }
}