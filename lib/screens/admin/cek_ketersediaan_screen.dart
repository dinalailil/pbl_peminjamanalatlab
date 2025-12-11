import 'package:flutter/material.dart';

class CekKetersediaanScreen extends StatelessWidget {
  final String namaLab;

  const CekKetersediaanScreen({super.key, required this.namaLab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: Column(
        children: [
          // ===================== HEADER GRADIENT ======================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
            child: Column(
              children: [
                // BACK BUTTON
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 10),

                // TITLE
                const Text(
                  "Cek Stok\nBarang",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // SUBTITLE (NAMA LAB)
                Text(
                  namaLab,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================== GRID BARANG ==========================
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              crossAxisSpacing: 20,
              mainAxisSpacing: 25,
              childAspectRatio: 0.78,

              children: [
                _itemCard(
                  image: "assets/proyektor.png",
                  nama: "Proyektor Epson",
                  kode: "Alt001",
                  tersedia: 5,
                  terpinjam: 2,
                ),
                _itemCard(
                  image: "assets/laptop.png",
                  nama: "Laptop Lenovo",
                  kode: "Alt002",
                  tersedia: 5,
                  terpinjam: 0,
                ),
                _itemCard(
                  image: "assets/mouse.png",
                  nama: "Mouse HP",
                  kode: "Alt003",
                  tersedia: 5,
                  terpinjam: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // CARD BARANG
  // ====================================================================
  Widget _itemCard({
    required String image,
    required String nama,
    required String kode,
    required int tersedia,
    required int terpinjam,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(image, height: 75),
          const SizedBox(height: 10),

          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Kode : $kode",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "tersedia : $tersedia\nTerpinjam : $terpinjam",
              style: TextStyle(
                height: 1.4,
                color: Colors.grey.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
