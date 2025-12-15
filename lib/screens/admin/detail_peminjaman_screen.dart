import 'package:flutter/material.dart';

class DetailPeminjamanScreen extends StatelessWidget {
  final String nama;

  const DetailPeminjamanScreen({super.key, required this.nama});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD2D2),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
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
                    Center(
                      child: Text(
                        nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // LIST BARANG
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _barangCard(
                    no: 1,
                    nama: "Alt001",
                    image: "assets/projector.png",
                    tglPinjam: "12 November 2025",
                    tglKembali: "20 November 2025",
                  ),
                  const SizedBox(height: 15),
                  _barangCard(
                    no: 2,
                    nama: "Alt002",
                    image: "assets/laptop.png",
                    tglPinjam: "02 Oktober 2025",
                    tglKembali: "03 Oktober 2025",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _barangCard({
    required int no,
    required String nama,
    required String image,
    required String tglPinjam,
    required String tglKembali,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            "$no.",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 15),
          Image.asset(image, width: 50),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text("Tgl Peminjaman : $tglPinjam",
                  style: const TextStyle(fontSize: 11)),
              Text("Tgl Pengembalian : $tglKembali",
                  style: const TextStyle(fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}
