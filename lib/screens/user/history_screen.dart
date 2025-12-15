import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      body: Column(
        children: [
          // =========================
          // 🔵 HEADER UNGU
          // =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff7f5eff), Color(0xff6b53ff)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                const Spacer(),
                const Text(
                  "History",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          // 🔥 LIST HISTORY
          // =========================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("peminjaman")
                  .where("user_uid", isEqualTo: uid)
                  .where("status", isEqualTo: "selesai")
                  .orderBy("tgl_pinjam", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.docs;

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada riwayat transaksi",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var map = data[index].data() as Map<String, dynamic>;

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
                          // GAMBAR
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              map["gambar"],
                              width: 70,
                              height: 70,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(width: 15),

                          // INFO HISTORY
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
                        ],
                      ),
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

  // ===========================
  // 📅 FORMAT TANGGAL
  // ===========================
  static String _format(Timestamp t) {
    DateTime d = t.toDate();
    return "${d.day} ${_bulan(d.month)} ${d.year}";
  }

  static String _bulan(int m) {
    const bulan = [
      "Jan","Feb","Mar","Apr","Mei","Jun",
      "Jul","Agu","Sep","Okt","Nov","Des"
    ];
    return bulan[m - 1];
  }
}
