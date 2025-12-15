import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final QueryDocumentSnapshot data;

  const FormPeminjamanScreen({
    super.key,
    required this.data,
  });

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaController = TextEditingController();
  TextEditingController keperluanController = TextEditingController();

  int jumlahPinjam = 1;
  DateTime? tglPinjam;
  DateTime? tglKembali;
  bool loading = false;

  // Variabel untuk menyimpan sisa stok yang benar-benar bisa dipinjam
  int stokBisaDipinjam = 0; 

  // ... (Fungsi pickDate sama seperti sebelumnya) ...
  Future<void> pickDate(BuildContext context, bool isPinjam) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isPinjam) tglPinjam = picked;
        else tglKembali = picked;
      });
    }
  }

Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (tglPinjam == null || tglKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi tanggal")));
      return;
    }

    // Validasi Terakhir: Cek apakah stok virtual cukup?
    if (stokBisaDipinjam < jumlahPinjam) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maaf! Stok rebutan. Sisa tersedia: $stokBisaDipinjam")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Kita pakai Transaction agar aman saat rebutan
      await FirebaseFirestore.instance.runTransaction((tx) async {
        // 1. Ambil Stok Fisik Terbaru
        DocumentSnapshot alatSnap = await tx.get(widget.data.reference);
        int stokFisik = (alatSnap['jumlah'] ?? 0) as int;

        // 2. Validasi Hard Limit Stok Fisik
        if (stokFisik < jumlahPinjam) { 
             throw Exception("Stok Gudang Habis!"); 
        }

        // 3. Buat Request (Tanpa Kurangi Stok Fisik)
        tx.set(FirebaseFirestore.instance.collection("peminjaman").doc(), {
          "user_uid": FirebaseAuth.instance.currentUser!.uid,
          
          "alat_id": widget.data.id,
          "kode_barang": widget.data['kode'],
          "nama_barang": widget.data['nama'],
          "gambar": widget.data['gambar'] ?? "",
          
          // ⭐ TAMBAHAN: AMBIL ARRAY LAB DARI DATA BARANG
          "lab": widget.data['lab'] ?? [], 

          "nama_peminjam": namaController.text,
          "keperluan": keperluanController.text,
          "jumlah_pinjam": jumlahPinjam,
          
          "tgl_pinjam": Timestamp.fromDate(tglPinjam!),
          "tgl_kembali": Timestamp.fromDate(tglKembali!),
          
          "status": "diajukan",
          "created_at": FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil diajukan!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
    
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data() as Map<String, dynamic>;
    final stokFisik = (map['jumlah'] as num).toInt();
    final warnaUngu = const Color(0xFF7A56FF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: warnaUngu,
        title: Text("Peminjaman (${map['kode']})", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          // --- STREAM BUILDER UNTUK MENGHITUNG STOK VIRTUAL ---
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('peminjaman')
                .where('nama_barang', isEqualTo: map['nama']) // Cari barang yg sama
                .where('status', isEqualTo: 'diajukan') // Cari yg statusnya booking
                .snapshots(),
            builder: (context, snapshot) {
              
              // 1. Hitung Total Booking Orang Lain
              int totalBooking = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  totalBooking += (doc['jumlah_pinjam'] as num).toInt();
                }
              }

              // 2. Hitung Stok Virtual (Sisa Bersih)
              stokBisaDipinjam = stokFisik - totalBooking;
              if (stokBisaDipinjam < 0) stokBisaDipinjam = 0; // Jaga-jaga error

              return ListView(
                children: [
                  Text(map['nama'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // --- INFO STOK YANG JUJUR ---
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sisa Stok Tersedia:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          "$stokBisaDipinjam", // Tampilkan Stok Virtual
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: stokBisaDipinjam > 0 ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                  if (totalBooking > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "⚠️ Ada $totalBooking barang sedang dalam antrian (booking)",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),

                  const SizedBox(height: 25),

                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: "Nama Peminjam", border: UnderlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Isi nama" : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: keperluanController,
                    decoration: const InputDecoration(labelText: "Keperluan", border: UnderlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Isi keperluan" : null,
                  ),
                  const SizedBox(height: 25),

                  const Text("Jumlah Pinjam", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // CONTROLLER JUMLAH
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade400))),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: jumlahPinjam > 1 ? () => setState(() => jumlahPinjam--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Expanded(
                          child: Text(jumlahPinjam.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          // Batasi Max Pinjam sesuai Stok Virtual, bukan Stok Fisik
                          onPressed: jumlahPinjam < stokBisaDipinjam ? () => setState(() => jumlahPinjam++) : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  ListTile(
                    title: Text(tglPinjam == null ? "Pilih Tanggal Pinjam" : "Pinjam: ${tglPinjam!.day}/${tglPinjam!.month}"),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () => pickDate(context, true),
                  ),
                  ListTile(
                    title: Text(tglKembali == null ? "Pilih Tanggal Kembali" : "Kembali: ${tglKembali!.day}/${tglKembali!.month}"),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () => pickDate(context, false),
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    // Disable tombol jika stok virtual habis
                    onPressed: (loading || stokBisaDipinjam == 0) ? null : submit,
                    style: ElevatedButton.styleFrom(backgroundColor: warnaUngu, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: Text(stokBisaDipinjam == 0 ? "Stok Habis / Full Booked" : "Ajukan Pinjaman"),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}