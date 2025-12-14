// search_screen.dart
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

  // 🔍 STREAM SEARCH
Stream<QuerySnapshot> searchAlat() {
  if (searchQuery.isEmpty) {
    return FirebaseFirestore.instance
        .collection('alat')
        .orderBy('nama_lower')
        .limit(10)
        .snapshots();
  }

  return FirebaseFirestore.instance
      .collection('alat')
      .orderBy('nama_lower') // 🔥 WAJIB
      .startAt([searchQuery])
      .endAt(['$searchQuery\uf8ff'])
      .snapshots();
}




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
      
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Cari barang (contoh: mouse)",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // 📦 HASIL SEARCH
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchAlat(), // ✅ FIXED
              builder: (context, snapshot) {
                if (searchQuery.isEmpty) {
                  return const Center(
                    child: Text(
                      "Ketik untuk mencari barang",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Barang tidak ditemukan"));
                }

                final data = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final map = item.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: map['gambar'] != null && map['gambar'] != ""
                          ? Image.network(map['gambar'], width: 50)
                          : const Icon(Icons.inventory),
                      title: Text(map['nama']),
                      subtitle: Text("Kode: ${map['kode']}"),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => DetailBarangModal(data: item),
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
