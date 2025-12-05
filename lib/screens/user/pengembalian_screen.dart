import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PengembalianScreen extends StatefulWidget {
  const PengembalianScreen({super.key});

  @override
  State<PengembalianScreen> createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianScreen> {
  int tabIndex = 0; // 0 = proses, 1 = selesai

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Column(
        children: [
          // header
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6A5AE0), Color(0xff836EF0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pengembalian Barang",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),

                // TAB SWITCH
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildTab("Proses", 0),
                    const SizedBox(width: 10),
                    buildTab("Selesai", 1),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // CONTENT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("peminjaman")
                  .where("status", isEqualTo: tabIndex == 0 ? "Dipinjam" : "Dikembalikan")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada data"));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return buildCard(data, doc.id);
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // TAB ITEM
  Widget buildTab(String title, int index) {
    bool active = tabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // CARD LIST
  Widget buildCard(Map<String, dynamic> data, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 65,
            width: 65,
            child: Image.network(
              data["gambar"] ?? "",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kode ${data["kode_barang"]}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${formatDate(data["tgl_pinjam"])} - ${formatDate(data["tgl_kembali"])}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text("Jumlah: 1", style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),

          // BUTTON PROSES / SELESAI
          if (tabIndex == 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              onPressed: () async {
                await FirebaseFirestore.instance.collection("peminjaman").doc(id).update({
                  "status": "Dikembalikan",
                });

                // tambah kembali stok barang
                final alat = await FirebaseFirestore.instance
                    .collection("alat")
                    .where("kode", isEqualTo: data["kode_barang"])
                    .limit(1)
                    .get();

                if (alat.docs.isNotEmpty) {
                  final jumlah = alat.docs.first["jumlah"] + 1;
                  await alat.docs.first.reference.update({
                    "jumlah": jumlah,
                    "status": "Tersedia",
                  });
                }
              },
              child: const Text("Proses"),
            )
        ],
      ),
    );
  }

  String formatDate(Timestamp t) {
    final d = t.toDate();
    return "${d.day}/${d.month}/${d.year}";
  }
}
