import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_peminjaman_screen.dart';

class DetailBarangModal extends StatelessWidget {
  final QueryDocumentSnapshot data;
  final String? labName;
  final int stokVirtual; //  1. TAMBAH PARAMETER STOK VIRTUAL

  const DetailBarangModal({
    Key? key,
    required this.data,
    this.labName,
    required this.stokVirtual, //  WAJIB DIISI DARI KATALOG
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final map = data.data() as Map<String, dynamic>;

    String nama = map['nama'] ?? "-";
    String kode = map['kode'] ?? "-";
    // String status = map['status'] ?? "-"; // Tidak dipakai lagi, pakai logika stokVirtual
    // int jumlah = ... // Tidak kita pakai untuk validasi tombol lagi
    String deskripsi = map['deskripsi'] ?? "Tidak ada deskripsi";
    String? gambar = map['gambar'];

    // Ambil array lab
    List labList = (map['lab'] is List) ? map['lab'] : [];
    String laboratorium = labList.isNotEmpty ? labList.join(", ") : "-";

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // GAMBAR
                if (gambar != null)
                  Image.network(gambar, height: 140, fit: BoxFit.contain)
                else
                  const Icon(Icons.image, size: 120),

                const SizedBox(height: 12),

                // NAMA
                Text(
                  nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                //  2. TAMPILKAN SISA STOK VIRTUAL (BUKAN FISIK)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sisa Stok: $stokVirtual", 
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        color: stokVirtual > 0 ? Colors.black54 : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Kode: $kode",
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // LABORATORIUM
                Text(
                  "Laboratorium: $laboratorium",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 220, 67, 241),
                  ),
                ),

                const SizedBox(height: 12),

                // DESKRIPSI
                Text(
                  deskripsi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),

                const SizedBox(height: 16),

                //  3. TOMBOL SEWA DENGAN LOGIKA STOK VIRTUAL
                // (Hanya muncul jika ada labName / dari menu search lab)
                if (labName != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: stokVirtual <= 0 // Matikan jika stok virtual habis
                          ? null
                          : () {
                              Navigator.pop(context); // Tutup modal

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormPeminjamanScreen(
                                    data: data, // kirim data barang
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4CAF50), // Hijau
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        stokVirtual <= 0 ? "Full Booked" : "Sewa",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // TOMBOL CLOSE (X) DI POJOK
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