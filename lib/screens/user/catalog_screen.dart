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

  // ★ STREAM berdasarkan lab + filter
Stream<QuerySnapshot> getFilteredStream() {
  Query alatRef = FirebaseFirestore.instance.collection('alat');

  // ⭐ Filter berdasarkan LAB (kalau datang dari home/search)
  if (widget.labName != null) {
    alatRef = alatRef.where('lab', arrayContains: widget.labName);
  }

  // ⭐ Filter status (tersedia / dipinjam)
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
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff7f5eff), Color(0xff6b53ff)],
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
              Padding(
  padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Tombol back kiri
      IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),

      // Judul di tengah
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

      // Placeholder untuk menyeimbangkan layout
      const SizedBox(width: 48),
    ],
  ),
),


                const SizedBox(height: 15),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search",
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
               // Filter Chips
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // SEMUA
    FilterChip(
      label: const Text("Semua"),
      selected: selectedFilter == "Semua",
      onSelected: (_) {
        setState(() {
          selectedFilter = "Semua";
        });
      },
    ),

    const SizedBox(width: 10),

    // TERSEDIA
    FilterChip(
      label: const Text("tersedia"),
      selected: selectedFilter == "tersedia",
      onSelected: (_) {
        setState(() {
          selectedFilter = "tersedia";
        });
      },
    ),

    const SizedBox(width: 10),

    // DIPINJAM
    FilterChip(
      label: const Text("dipinjam"),
      selected: selectedFilter == "dipinjam",
      onSelected: (_) {
        setState(() {
          selectedFilter = "dipinjam";
        });
      },
    ),
  ],
),

              ],
            ),
          ),

          const SizedBox(height: 15),

          // LIST GRID VIEW
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFilteredStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.docs;

                // Search filter
                if (searchQuery.isNotEmpty) {
                  data = data
                      .where((item) =>
                          (item.data() as Map<String, dynamic>)['nama']
                              .toString()
                              .toLowerCase()
                              .contains(searchQuery))
                      .toList();
                }

                if (data.isEmpty) {
                  return const Center(
                    child:
                        Text("Tidak ada barang", style: TextStyle(fontSize: 16)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var item = data[index];
                    final map = item.data() as Map<String, dynamic>;

                    String nama = map['nama'] ?? "-";
                    String kode = map['kode'] ?? "-";
                    String status = map['status'] ?? "-";
                    int jumlah = (map['jumlah'] is num)
                        ? (map['jumlah'] as num).toInt()
                        : 0;
                    String? gambar = map['gambar'];

                    return InkWell(
                      onTap: () {
                       showDialog(
  context: context,
  builder: (_) => DetailBarangModal(
    data: item,
    labName: widget.labName, 
  ),
);

                      },
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
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: gambar != null
                                  ? Image.network(gambar, fit: BoxFit.contain)
                                  : const Icon(Icons.image,
                                      size: 70, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nama,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text("Kode: $kode",
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text("Stok: $jumlah",
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    status.toLowerCase() == "tersedia"
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: status.toLowerCase() == "tersedia"
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
