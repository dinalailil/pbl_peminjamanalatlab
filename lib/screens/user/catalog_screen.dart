import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_barang_modal.dart';

class CatalogScreen extends StatefulWidget {
  final String? labName; // ★ menerima nama lab

  const CatalogScreen({Key? key, this.labName}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String selectedFilter = "Semua";
  String searchQuery = "";

  // ★ STREAM utama: Data fisik barang dari gudang
  Stream<QuerySnapshot> getFilteredStream() {
    Query alatRef = FirebaseFirestore.instance.collection('alat');

    // ⭐ Filter berdasarkan LAB
    if (widget.labName != null) {
      alatRef = alatRef.where('lab', arrayContains: widget.labName);
    }

    // ⭐ Filter status fisik (tersedia/habis di gudang)
    // Note: Filter 'tersedia' di sini hanya mengecek stok fisik > 0.
    // Pengecekan 'Full Booked' dilakukan nanti di dalam builder.
    if (selectedFilter != "Semua") {
      alatRef = alatRef.where('status', isEqualTo: selectedFilter);
    }

    return alatRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f3f3),
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                // Warna Gradien Ungu (Sama dengan SearchScreen)
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
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
                // Title + Back Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Katalog Barang",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer penyeimbang
                  ],
                ),

                const SizedBox(height: 15),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Cari alat...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip("Semua"),
                    const SizedBox(width: 10),
                    _buildFilterChip("tersedia"),
                    const SizedBox(width: 10),
                    _buildFilterChip("dipinjam"),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ================= LIST GRID VIEW =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFilteredStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                // Client-side Searching
                if (searchQuery.isNotEmpty) {
                  docs = docs.where((item) {
                    var data = item.data() as Map<String, dynamic>;
                    return (data['nama'] ?? "")
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada barang",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        0.75, // Aspect ratio disesuaikan agar muat overlay
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var item = docs[index];
                    var data = item.data() as Map<String, dynamic>;

                    // ========================================================
                    // LOGIKA STOK VIRTUAL (NESTED STREAM)
                    // ========================================================
                    // Kita buat stream lagi untuk mengecek apakah barang ini sedang di-booking orang lain
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('peminjaman')
                          .where(
                            'nama_barang',
                            isEqualTo: data['nama'],
                          ) // Cari booking barang ini
                          .where(
                            'status',
                            isEqualTo: 'diajukan',
                          ) // Hanya yang statusnya booking
                          .snapshots(),
                      builder: (context, bookingSnap) {
                        // 1. Hitung Stok Fisik (Gudang)
                        int stokFisik = (data['jumlah'] as num? ?? 0).toInt();

                        // 2. Hitung Total Booking (Antrian)
                        int totalBooking = 0;
                        if (bookingSnap.hasData) {
                          for (var doc in bookingSnap.data!.docs) {
                            totalBooking += (doc['jumlah_pinjam'] as num? ?? 0)
                                .toInt();
                          }
                        }

                        // 3. Hitung Stok Virtual (Yang Tampil ke User)
                        int stokTersedia = stokFisik - totalBooking;

                        // Tentukan apakah HABIS atau TERSEDIA
                        bool isHabis = stokTersedia <= 0;
                        // Jangan tampilkan angka minus
                        int displayStock = stokTersedia > 0 ? stokTersedia : 0;

                        return _buildItemCard(
                          context,
                          item,
                          data,
                          displayStock,
                          isHabis,
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

  // Widget Helper Filter Chip
  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: selectedFilter == label,
      onSelected: (_) {
        setState(() {
          selectedFilter = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xff7f5eff).withOpacity(0.2),
      labelStyle: TextStyle(
        color: selectedFilter == label ? const Color(0xff7f5eff) : Colors.black,
        fontWeight: selectedFilter == label
            ? FontWeight.bold
            : FontWeight.normal,
      ),
    );
  }

  // =======================================================================
  // KARTU BARANG (UPDATED - FIX ERROR MERAH)
  // =======================================================================
  Widget _buildItemCard(
    BuildContext context,
    QueryDocumentSnapshot doc,
    Map<String, dynamic> data,
    int stokRealtime,
    bool isHabis,
  ) {
    return InkWell(
      key: Key('item_${data['kode']}'),
      // --- PERBAIKAN UTAMA DI SINI ---
      onTap: isHabis
          ? null // Kalau habis, tidak bisa diklik
          : () {
              showDialog(
                context: context,
                builder: (_) => DetailBarangModal(
                  data: doc,
                  labName: widget.labName,
                  stokVirtual: stokRealtime, // <--- JANGAN LUPA BARIS INI !!
                ),
              );
            },

      // ... (Sisa kode UI tampilan kartu di bawah ini biarkan saja) ...
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isHabis ? 0.5 : 1.0,
                    child: Center(
                      child:
                          data['gambar'] != null &&
                              data['gambar'].toString().isNotEmpty
                          ? Image.network(data['gambar'], fit: BoxFit.contain)
                          : const Icon(
                              Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  if (isHabis)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Habis",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data['nama'] ?? "-",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isHabis ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data['kode'] ?? "-",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sisa: $stokRealtime",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isHabis ? Colors.red : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isHabis
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isHabis ? "Full Booked" : "Tersedia",
                    style: TextStyle(
                      color: isHabis
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
