import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_barang_modal.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A56FF),
        title: const Text(
          "Cari Barang",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ================= INPUT SEARCH =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Cari barang (contoh: mouse, lan)...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Simpan lowercase biar gampang
                });
              },
            ),
          ),

          // ================= HASIL SEARCH =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // 1. AMBIL SEMUA DATA ALAT (Tanpa filter query firestore)
              stream: FirebaseFirestore.instance.collection('alat').snapshots(),
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Data alat kosong"));
                }

                // 2. FILTER DATA DI SINI (CLIENT SIDE)
                // Ini yang membuat pencarian jadi "Contains" (bisa cari kata di tengah)
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String namaBarang = (data['nama'] ?? "").toString().toLowerCase();
                  
                  // Kalau search kosong, tampilkan semua (atau return false jika ingin sembunyikan)
                  if (searchQuery.isEmpty) return true; 

                  // Cek apakah nama mengandung kata kunci
                  return namaBarang.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Barang tidak ditemukan"));
                }

                // 3. TAMPILKAN LIST
                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final item = filteredDocs[index];
                    final map = item.data() as Map<String, dynamic>;

                    // ========================================================
                    // 🔥 LOGIKA STOK VIRTUAL (STREAM DI DALAM LIST)
                    // ========================================================
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('peminjaman')
                          .where('nama_barang', isEqualTo: map['nama'])
                          .where('status', isEqualTo: 'diajukan')
                          .snapshots(),
                      builder: (context, bookingSnap) {
                        
                        // A. Ambil Stok Fisik
                        int stokFisik = (map['jumlah'] as num? ?? 0).toInt();

                        // B. Hitung Total Booking
                        int totalBooking = 0;
                        if (bookingSnap.hasData) {
                          for (var doc in bookingSnap.data!.docs) {
                            totalBooking += (doc['jumlah_pinjam'] as num? ?? 0).toInt();
                          }
                        }

                        // C. Hitung Sisa Stok Virtual
                        int stokTersedia = stokFisik - totalBooking;
                        bool isHabis = stokTersedia <= 0;
                        int displayStok = stokTersedia > 0 ? stokTersedia : 0;

                        return ListTile(
                          // Gambar
                          leading: map['gambar'] != null && map['gambar'] != ""
                              ? Image.network(map['gambar'], width: 50, fit: BoxFit.cover)
                              : const Icon(Icons.inventory, size: 40),
                          
                          // Nama Barang (Dicoret jika habis)
                          title: Text(
                            map['nama'] ?? "-",
                            style: TextStyle(
                              color: isHabis ? Colors.grey : Colors.black,
                              decoration: isHabis ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          
                          // Info Stok & Status
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Kode: ${map['kode']}"),
                              Text(
                                isHabis ? "Full Booked" : "Sisa Stok: $displayStok",
                                style: TextStyle(
                                  color: isHabis ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ],
                          ),

                          // Aksi Klik (Kirim stokVirtual ke Modal)
                          onTap: isHabis 
                              ? null // Matikan klik jika habis
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => DetailBarangModal(
                                      data: item,
                                      stokVirtual: displayStok, // ✅ KIRIM STOK VIRTUAL
                                    ),
                                  );
                                },
                        );
                      },
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
}