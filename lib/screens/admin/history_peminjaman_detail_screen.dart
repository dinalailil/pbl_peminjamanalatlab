import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPeminjamanDetailScreen extends StatelessWidget {
  final String namaUser;
  final List<DocumentSnapshot> daftarRiwayat;

  const HistoryPeminjamanDetailScreen({
    super.key,
    required this.namaUser,
    required this.daftarRiwayat,
  });

  String formatDate(Timestamp? t) {
    if (t == null) return "-";
    return DateFormat("dd MMMM yyyy", "id_ID").format(t.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // ====================== HEADER ======================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C6BFF), Color(0xFF7A5CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Riwayat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    namaUser,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====================== LIST RIWAYAT ======================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: daftarRiwayat.length,
              itemBuilder: (context, index) {
                final d =
                    daftarRiwayat[index].data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= NOMOR =================
                      Text(
                        "${index + 1}.",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ================= DETAIL =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // KODE BARANG (JUDUL SESUAI UI)
                            Text(
                              d["kode_barang"] ?? "-",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            _rowDetail(
                                "Laboratorium", d["nama_lab"] ?? "-"),
                            _rowDetail(
                                "Nama Barang", d["nama_barang"] ?? "-"),
                            _rowDetail(
                                "Jumlah", d["jumlah_pinjam"] ?? "-"),
                            _rowDetail(
                                "Tgl Peminjaman",
                                formatDate(d["tgl_pinjam"])),
                            _rowDetail(
                                "Tgl Pengembalian",
                                formatDate(d["tgl_kembali"])),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ====================== HELPER ======================
  Widget _rowDetail(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 160,
            child: Text(
              value?.toString() ?? "-",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}