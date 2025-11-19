import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String selectedFilter = "Semua";
  String searchQuery = "";

 
  Stream<QuerySnapshot> getFilteredStream() {
    if (selectedFilter == "Semua") {
      return FirebaseFirestore.instance
          .collection('alat')
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('alat')
        .where('status', isEqualTo: selectedFilter)
        .snapshots();
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
             Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      "Katalog Barang",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // Tombol Back
    IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.pop(context);
      },
    )
  ],
),

                const SizedBox(height: 15),

                // SEARCH BOX
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey),
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

                // FILTER TOGGLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilterChip(
                      label: const Text("Tersedia"),
                      selected: selectedFilter == "Tersedia",
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = "Tersedia";
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: const Text("Dipinjam"),
                      selected: selectedFilter == "Dipinjam",
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = "Dipinjam";
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: const Text("Semua"),
                      selected: selectedFilter == "Semua",
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = "Semua";
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // LIST ITEM
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFilteredStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.docs;

                // FILTER SEARCH
                if (searchQuery.isNotEmpty) {
                  data = data
                      .where((item) =>
                          item['nama'].toString().toLowerCase().contains(searchQuery))
                      .toList();
                }

                // JIKA DATA KOSONG
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada barang",
                      style: TextStyle(fontSize: 16),
                    ),
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

                    String nama = item['nama'] ?? "-";
                    String kode = item['kode'] ?? "-";
                    String status = item['status'] ?? "-";
                    String? gambar = item['gambar'];

                    return Container(
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
                                ? Image.network(gambar!)
                                : const Icon(
                                    Icons.image,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nama,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Kode: $kode",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // BADGE STATUS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: status == "Tersedia"
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: status == "Tersedia"
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
