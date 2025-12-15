import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      body: Column(
        children: [
          // =========================
          //  HEADER UNGU
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

          // =========================
          //  LIST STREAM NOTIFIKASI
          // =========================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("peminjaman")
                  .where("user_uid", isEqualTo: uid)
                  .orderBy("created_at", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada notifikasi",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                var data = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var item = data[index];
                    var map = item.data() as Map<String, dynamic>;

                    print("GAMBAR VALUE: ${map["gambar"]} | TYPE: ${map["gambar"].runtimeType}");

                    // ===========================
                    //  STATUS FILTER
                    // ===========================
                    String status = map["status"] ?? "-";
                    String statusText = "";
                    Color color = Colors.green;

                    if (status == "disetujui") {
                      statusText = "Proses Disetujui";
                      color = Colors.blue;
                    } else if (status == "dipinjam") {
                      statusText = "Proses Peminjaman";
                      color = Colors.green;
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
                          // ===========================
                          //  GAMBAR
                          // ===========================
                          Container(
  width: 70,
  height: 70,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    image: (map["gambar"] != null && map["gambar"].toString().trim().isNotEmpty)
        ? DecorationImage(
            image: NetworkImage(map["gambar"].toString().trim()),
            fit: BoxFit.cover,
          )
        : null,
    // HAPUS COLOR JIKA ADA GAMBAR
    color: (map["gambar"] == null || map["gambar"].toString().trim().isEmpty)
        ? Colors.grey.shade200
        : null,
  ),
  child: (map["gambar"] == null || map["gambar"].toString().trim().isEmpty)
      ? const Icon(Icons.image, size: 40)
      : null,
),


                          const SizedBox(width: 15),
                          

                          // ===========================
                          // INFORMASI
                          // ===========================
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
                                  "Jumlah: ${map['jumlah_pinjam'] ?? 1}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ===========================
                          // BADGE STATUS
                          // ===========================
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
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

  // ===============================
  // FORMAT TANGGAL
  // ===============================
  static String _format(Timestamp? t) {
    if (t == null) return "-";
    DateTime d = t.toDate();
    return "${d.day} ${_bulan(d.month)} ${d.year}";
  }

  static String _bulan(int m) {
    const bulan = [
      "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
      "Jul", "Agu", "Sep", "Okt", "Nov", "Des"
    ];
    return bulan[m - 1];
  }
}
