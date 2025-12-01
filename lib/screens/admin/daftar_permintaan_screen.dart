import 'package:flutter/material.dart';

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
            height: 180,
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Daftar\nPermintaan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================== LIST ==================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildPermintaanCard(
                  avatarColor: Colors.blue.shade300,
                  kode: "",
                  tanggal: "",
                  withText: false,
                ),

                const SizedBox(height: 20),

                _buildPermintaanCard(
                  avatarColor: Colors.red.shade300,
                  kode: "Kode Alt002",
                  tanggal: "26 Okt 2025 - 27 Okt 2025",
                ),

                const SizedBox(height: 20),

                _buildPermintaanCard(
                  avatarColor: Colors.orange.shade300,
                  kode: "Kode Alt001",
                  tanggal: "01 Sept 2025 - 02 Okt 2025",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== CARD COMPONENT ==================
  Widget _buildPermintaanCard({
    required Color avatarColor,
    required String kode,
    required String tanggal,
    bool withText = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: avatarColor,
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),

          const SizedBox(width: 16),

          // Keterangan
          Expanded(
            child: withText
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kode,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tanggal,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      )
                    ],
                  )
                : const SizedBox(),
          ),

          // Lihat Detail
          if (withText)
            const Text(
              "Lihat Detail",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}
