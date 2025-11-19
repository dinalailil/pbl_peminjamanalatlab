import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPeminjamanScreen extends StatefulWidget {
  const FormPeminjamanScreen({super.key});

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  // Controller untuk input teks
  final _barangCtrl = TextEditingController();
  final _alasanCtrl = TextEditingController();
  
  // Variabel untuk tanggal
  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;

  bool _isLoading = false;

  // Fungsi untuk memunculkan Kalender
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Tidak boleh pilih tanggal lampau
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalPinjam = picked;
        } else {
          _tanggalKembali = picked;
        }
      });
    }
  }

  // Fungsi Kirim Data ke Firestore
  Future<void> _submitForm() async {
    if (_barangCtrl.text.isEmpty || _alasanCtrl.text.isEmpty || _tanggalPinjam == null || _tanggalKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      // Ambil Nama User dari Firestore dulu biar lengkap
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      String namaUser = userDoc.get('nama');

      // Simpan ke Collection 'peminjaman'
      await FirebaseFirestore.instance.collection('peminjaman').add({
        'uid': user.uid,
        'nama_peminjam': namaUser,
        'barang': _barangCtrl.text,
        'alasan': _alasanCtrl.text,
        'tgl_pinjam': Timestamp.fromDate(_tanggalPinjam!), // Convert ke format Firebase
        'tgl_kembali': Timestamp.fromDate(_tanggalKembali!),
        'status': 'Pending', // Default status menunggu admin
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      
      // Tampilkan sukses & kembali
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permintaan berhasil dikirim!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Kembali ke Dashboard

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar Transparan dengan Judul
      appBar: AppBar(
        title: const Text("Form Peminjaman", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Isi Data Peminjaman",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // INPUT BARANG
            _buildInputLabel("Nama Barang"),
            TextField(
              controller: _barangCtrl,
              decoration: _inputDecoration("Contoh: Proyektor Epson"),
            ),
            const SizedBox(height: 20),

            // INPUT TANGGAL (Row biar sebelahan)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Tgl Pinjam"),
                      GestureDetector(
                        onTap: () => _pickDate(true),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(
                                _tanggalPinjam == null 
                                ? "Pilih Tgl" 
                                : "${_tanggalPinjam!.day}/${_tanggalPinjam!.month}/${_tanggalPinjam!.year}",
                                style: TextStyle(color: _tanggalPinjam == null ? Colors.grey : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Tgl Kembali"),
                      GestureDetector(
                        onTap: () => _pickDate(false),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_busy, size: 18, color: Colors.orange),
                              const SizedBox(width: 10),
                              Text(
                                _tanggalKembali == null 
                                ? "Pilih Tgl" 
                                : "${_tanggalKembali!.day}/${_tanggalKembali!.month}/${_tanggalKembali!.year}",
                                style: TextStyle(color: _tanggalKembali == null ? Colors.grey : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // INPUT ALASAN
            _buildInputLabel("Keperluan / Alasan"),
            TextField(
              controller: _alasanCtrl,
              maxLines: 3, // Biar kotaknya agak tinggi
              decoration: _inputDecoration("Contoh: Untuk presentasi Sidang Skripsi"),
            ),
            const SizedBox(height: 40),

            // TOMBOL SUBMIT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Ajukan Peminjaman", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Label Judul Input
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
    );
  }

  // Widget Helper untuk Style Input
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}