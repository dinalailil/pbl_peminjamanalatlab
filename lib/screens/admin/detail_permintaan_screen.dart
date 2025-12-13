import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPermintaanScreen extends StatelessWidget {
  final QueryDocumentSnapshot data;

  const DetailPermintaanScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final pem = data.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      body: Column(
        children: [
          // ================= HEADER =================
          Stack(
            children: [
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
                  "Detail\nPermintaan",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Positioned(
                top: 50,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ================= CARD DETAIL =================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Konfirmasi Peminjaman",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 20),

                _rowInfo("Nama", pem['nama_peminjam']),
                _rowInfo("Kode Alat", pem['kode_barang']),
                _rowInfo("Laboratorium", pem['nama_barang']),
                _rowInfo("Jumlah", pem['jumlah_pinjam'].toString()),
                _rowInfo("Tgl Peminjaman", formatTanggal(pem['tgl_pinjam'])),
                _rowInfo("Tgl Pengembalian", formatTanggal(pem['tgl_kembali'])),

                const SizedBox(height: 25),

                // ================= BUTTON DINAMIS =================
                _buildActionButtons(context, pem['status']),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= ROW INFO =================
  Widget _rowInfo(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$left :", style: const TextStyle(fontSize: 15)),
          Flexible(
            child: Text(
              right,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TOMBOL DINAMIS SESUAI STATUS =================
  Widget _buildActionButtons(BuildContext context, String status) {
  // ==== STATUS DIAJUKAN ====
    if (status == "diajukan") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => updateStatus(context, "disetujui"),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Ya",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          GestureDetector(
            onTap: () => updateStatus(context, "ditolak"),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Tidak",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    // ==== STATUS DISETUJUI ====
    if (status == "disetujui") {
      return Center(
        child: GestureDetector(
          onTap: () => updateStatus(context, "selesai"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF764BA2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Konfirmasi Pengembalian",
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // ==== STATUS DITOLAK ====
    if (status == "ditolak") {
      return const Center(
        child: Text(
          "Pengajuan telah ditolak",
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 243, 6, 6),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // ==== STATUS SELESAI ====
    if (status == "selesai") {
      // Tidak menampilkan apa pun
      return const SizedBox();
    }

    return const SizedBox();
  }

  // ================= UPDATE STATUS DATABASE =================
  Future<void> updateStatus(BuildContext context, String status) async {
    try {
      await FirebaseFirestore.instance.collection("peminjaman").doc(data.id).update({
        "status": status,
        "updated_at": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status diperbarui menjadi: $status")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui: $e")),
      );
    }
  }

  // ================= FORMAT TANGGAL =================
  String formatTanggal(Timestamp t) {
    final date = t.toDate();
    const bulan = [
      "",
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return "${date.day} ${bulan[date.month]} ${date.year}";
  }
}