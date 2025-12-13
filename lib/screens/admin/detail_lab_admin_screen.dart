import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'form_alat_screen.dart'; 

class DetailLabAdminScreen extends StatefulWidget {
  final String namaLab; 

  const DetailLabAdminScreen({super.key, required this.namaLab});

  @override
  State<DetailLabAdminScreen> createState() => _DetailLabAdminScreenState();
}

class _DetailLabAdminScreenState extends State<DetailLabAdminScreen> {
  // Palette Warna Modern
  final Color primaryColorStart = const Color(0xFF8E78FF);
  final Color primaryColorEnd = const Color(0xFF764BA2);
  final Color cardColor = Colors.white;
  final Color textPrimary = const Color(0xFF2D3436);
  final Color textSecondary = const Color(0xFF636E72);

  // Navigasi ke Form
  void _navigateToForm({String? docId, Map<String, dynamic>? data}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormAlatScreen(
          namaLab: widget.namaLab,
          docId: docId,
          data: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Background abu sangat muda (Clean)
      
      // Floating Action Button dengan Gradient
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [primaryColorStart, primaryColorEnd]),
          boxShadow: [
            BoxShadow(color: primaryColorStart.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToForm(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tambah Unit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),

      body: Column(
        children: [
          // --- HEADER MODERN ---
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColorStart, primaryColorEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: primaryColorEnd.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                // Navigasi Back
                Align(
                  alignment: Alignment.centerLeft, 
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(widget.namaLab, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text("Admin Dashboard", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- LIST KATALOG BARANG ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('alat')
                  .where('lab', arrayContains: widget.namaLab)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryColorStart));
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 15),
                        Text("Belum ada alat di lab ini", style: TextStyle(color: textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // Padding bawah besar utk FAB
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 15, 
                    mainAxisSpacing: 15, 
                    childAspectRatio: 0.68, // Rasio kartu ideal
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    
                    return _buildItemCard(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KARTU BARANG (ELEGANT UI) ---
  Widget _buildItemCard(String docId, Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _navigateToForm(docId: docId, data: data),
          splashColor: primaryColorStart.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gambar dengan Hero Animation
                Expanded(
                  child: Hero(
                    tag: docId, // Tag unik untuk animasi transisi
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          data['gambar'] ?? '', 
                          fit: BoxFit.contain,
                          errorBuilder: (c,e,s) => Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[300]),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 2. Info Nama & Kode
                Text(
                  data['nama'] ?? 'Tanpa Nama', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textPrimary),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 2),
                Text(
                  data['kode'] ?? '#-', 
                  style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500)
                ),
                
                const SizedBox(height: 12),
                
                // 3. Info Stok Realtime (Tanpa Booking)
                _buildRealtimeStock(data['nama'], data['jumlah'] ?? 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET LOGIKA STOK REALTIME ---
  Widget _buildRealtimeStock(String namaBarang, int totalInventory) {
    return StreamBuilder<QuerySnapshot>(
      // Hanya ambil yang statusnya 'disetujui' (Barang sedang dipinjam)
      stream: FirebaseFirestore.instance.collection('peminjaman')
          .where('nama_barang', isEqualTo: namaBarang)
          .where('status', isEqualTo: 'disetujui')
          .snapshots(),
      builder: (c, s) {
        int currentlyBorrowed = 0;
        
        if (s.hasData) {
          // Hitung total item yang sedang dipinjam (sum field 'jumlah_pinjam')
          for (var doc in s.data!.docs) {
             var data = doc.data() as Map<String, dynamic>;
             // Ambil jumlah_pinjam, default 1 jika field tidak ada
             currentlyBorrowed += (data['jumlah_pinjam'] as num? ?? 1).toInt();
          }
        }

        // Hitung Sisa di Rak (Stok Total - Sedang Dipinjam)
        int availableOnShelf = totalInventory; // Karena logika kita stok database sudah dikurangi saat approve, maka 'jumlah' database adalah Available.
        // TAPI: Jika logika 'prosesPeminjaman' kamu mengurangi stok di database 'alat', maka:
        // Stok di DB = Stok Tersedia.
        // Jadi kita tidak perlu pengurangan di sini.
        // Variable 'totalInventory' adalah data['jumlah'] dari Firestore 'alat'.
        
        // Cek Logikamu:
        // Jika User Pinjam -> Stok DB tetap.
        // Jika Admin Terima -> Stok DB Berkurang (-1).
        // BERARTI: Data di DB 'alat' adalah data "Stok Tersedia (Available)".
        
        int stokTersedia = totalInventory; 

        return Row(
          children: [
            // Badge Tersedia (Hijau)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: stokTersedia > 0 ? const Color(0xFFE3FCEF) : const Color(0xFFFFF1F0), // Hijau muda / Merah muda
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text("Tersedia", style: TextStyle(fontSize: 10, color: stokTersedia > 0 ? const Color(0xFF00B894) : Colors.red)),
                    const SizedBox(height: 2),
                    Text("$stokTersedia", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: stokTersedia > 0 ? const Color(0xFF00B894) : Colors.red)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),

            // Badge Dipinjam (Orange/Purple)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5), // Ungu muda banget
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text("Dipinjam", style: TextStyle(fontSize: 10, color: primaryColorEnd)),
                    const SizedBox(height: 2),
                    Text("$currentlyBorrowed", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColorEnd)),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}