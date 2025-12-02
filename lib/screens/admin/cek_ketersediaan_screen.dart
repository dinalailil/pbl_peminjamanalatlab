import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CekKetersediaanScreen extends StatelessWidget {
  const CekKetersediaanScreen({super.key});

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

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
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
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
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Cek Ketersediaan\nBarang",
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

          // ================== GRID LIST FIRESTORE ==================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('alat').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Terjadi kesalahan..."));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final map = (item.data() as Map<String, dynamic>?) ?? {};

                      // Debug print to inspect document fields at runtime
                      debugPrint('alat doc ${item.id}: $map');

                      final totalRaw = map['total'];
                      final terpinjamRaw = map['terpinjam'];

                      final int total = _toInt(totalRaw);
                      final int terpinjam = _toInt(terpinjamRaw);
                      final int tersedia = total - terpinjam;

                      final imageName = (map['image'] as String?) ?? '';
                      final imagePath = imageName.isNotEmpty
                          ? 'assets/images/$imageName'
                          : '';

                      return _buildItemCard(
                        imagePath: imagePath,
                        name: map['nama'] ?? '-',
                        kode: map['kode'] ?? '-',
                        tersedia: tersedia,
                        terpinjam: terpinjam,
                        rawData: map,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================== CARD DESIGN ==================
  Widget _buildItemCard({
    required String imagePath,
    required String name,
    required String kode,
    required int tersedia,
    required int terpinjam,
    Map<String, dynamic>? rawData,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.black26,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.black26,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              "Kode : $kode",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              "tersedia : $tersedia\nTerpinjam : $terpinjam",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            // optional: show raw debug info when stock is zero to help debugging
            if ((tersedia <= 0) && rawData != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  rawData.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
