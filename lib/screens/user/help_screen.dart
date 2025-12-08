import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Bantuan & FAQ", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _FaqTile(
            question: "Bagaimana cara meminjam alat?",
            answer: "Masuk ke menu Transaksi > Peminjaman Baru. Pilih alat yang tersedia, isi tanggal pinjam dan kembali, lalu ajukan.",
          ),
          _FaqTile(
            question: "Berapa lama batas peminjaman?",
            answer: "Batas peminjaman maksimal adalah 7 hari. Jika lebih, harap hubungi admin lab.",
          ),
          _FaqTile(
            question: "Apa yang terjadi jika alat rusak?",
            answer: "Peminjam bertanggung jawab penuh. Silakan lapor ke admin untuk proses penggantian atau perbaikan.",
          ),
          _FaqTile(
            question: "Bagaimana cara mengembalikan alat?",
            answer: "Bawa alat ke lab, lalu buka menu Transaksi > Pengembalian di aplikasi untuk konfirmasi pengembalian.",
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
          ),
        ],
      ),
    );
  }
}