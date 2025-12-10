// detail_barang_modal.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_peminjaman_screen.dart';

class DetailBarangModal extends StatelessWidget {
  final QueryDocumentSnapshot data;

  const DetailBarangModal({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final map = data.data() as Map<String, dynamic>;

    String nama = map['nama'] ?? "-";
    String kode = map['kode'] ?? "-";
    String status = map['status'] ?? "-";
    int jumlah = (map['jumlah'] is num) ? (map['jumlah'] as num).toInt() : 0;
    String deskripsi = map['deskripsi'] ?? "Tidak ada deskripsi";
    String? gambar = map['gambar'];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Kartu putih
          Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (gambar != null)
                  Image.network(gambar, height: 140, fit: BoxFit.contain)
                else
                  const Icon(Icons.image, size: 120),
                
                const SizedBox(height: 12),

                Text(nama,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Jumlah : $jumlah",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                    const SizedBox(width: 12),
                    Text("Kode : $kode",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ],
                ),

                const SizedBox(height: 12),

                Text(deskripsi,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13)),

                const SizedBox(height: 18),

                // Tombol Sewa → pindah halaman
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: jumlah == 0
                        ? null
                        : () {
                            Navigator.of(context).pop(); // Tutup dialog
                            
                            // Pindah halaman ke Form Peminjaman
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FormPeminjamanScreen(data: data),
                              ),
                            );
                          },
                    child: Text(jumlah == 0 ? "Stok Habis" : "Sewa"),
                  ),
                ),
              ],
            ),
          ),

          // Tombol close
          Positioned(
            right: -10,
            top: -10,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
