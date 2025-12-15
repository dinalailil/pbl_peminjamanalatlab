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
      // backgroundColor disesuaikan agar lengkungan terlihat
      backgroundColor: const Color(0xfff3f3f3), 
      
      appBar: AppBar(
        // 1. Buat background transparan & hilangkan shadow bawaan
        backgroundColor: Colors.transparent,
        elevation: 0,
        
        // 2. Judul & Icon
        title: const Text(
          "Cari Barang",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        
        // 3. INI BAGIAN PENTING: Gradient + Lengkungan (BorderRadius)
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff7f5eff), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // 🔥 MENAMBAHKAN LENGKUNGAN DI BAWAH 🔥
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30), // Sesuaikan angka ini (20-40)
            ),
          ),
        ),
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
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // Hilangkan garis border agar lebih bersih
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // ================= HASIL SEARCH =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // 1. AMBIL SEMUA DATA ALAT
              stream: FirebaseFirestore.instance.collection('alat').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Data alat kosong"));
                }

                // 2. FILTER DATA (CLIENT SIDE)
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String namaBarang = (data['nama'] ?? "").toString().toLowerCase();
                  
                  if (searchQuery.isEmpty) return true; 
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

                    // LOGIKA STOK VIRTUAL
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('peminjaman')
                          .where('nama_barang', isEqualTo: map['nama'])
                          .where('status', isEqualTo: 'diajukan')
                          .snapshots(),
                      builder: (context, bookingSnap) {
                        
                        int stokFisik = (map['jumlah'] as num? ?? 0).toInt();
                        int totalBooking = 0;
                        
                        if (bookingSnap.hasData) {
                          for (var doc in bookingSnap.data!.docs) {
                            totalBooking += (doc['jumlah_pinjam'] as num? ?? 0).toInt();
                          }
                        }

                        int stokTersedia = stokFisik - totalBooking;
                        bool isHabis = stokTersedia <= 0;
                        int displayStok = stokTersedia > 0 ? stokTersedia : 0;

                        return Container(
                          // Tambahkan margin & dekorasi agar list terlihat seperti Card
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                               BoxShadow(
                                 color: Colors.grey.withOpacity(0.1),
                                 blurRadius: 5,
                                 offset: const Offset(0, 3)
                               )
                            ]
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: map['gambar'] != null && map['gambar'] != ""
                                  ? Image.network(map['gambar'], width: 50, height: 50, fit: BoxFit.cover)
                                  : Container(
                                      width: 50, height: 50, 
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.inventory, size: 30)
                                    ),
                            ),
                            
                            title: Text(
                              map['nama'] ?? "-",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isHabis ? Colors.grey : Colors.black,
                                decoration: isHabis ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Kode: ${map['kode']}", style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  isHabis ? "Full Booked" : "Sisa Stok: $displayStok",
                                  style: TextStyle(
                                    color: isHabis ? Colors.red : const Color.fromARGB(255, 158, 76, 175),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                  ),
                                ),
                              ],
                            ),

                            onTap: isHabis 
                                ? null 
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => DetailBarangModal(
                                        data: item,
                                        stokVirtual: displayStok,
                                      ),
                                    );
                                  },
                          ),
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