import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Data FAQ (Pertanyaan & Jawaban)
  final List<Map<String, String>> _faqData = const [
    {
      "q": "Bagaimana cara meminjam alat?",
      "a": "Masuk ke menu Beranda, pilih 'Pinjam Alat' atau klik Search Bar. Cari barang yang diinginkan, tekan tombol '+', lalu isi formulir tanggal peminjaman dan alasan."
    },
    {
      "q": "Berapa lama batas peminjaman?",
      "a": "Batas peminjaman standar adalah 7 hari. Jika Anda membutuhkan waktu lebih lama, silakan hubungi admin lab atau ajukan perpanjangan sebelum tanggal jatuh tempo."
    },
    {
      "q": "Apa arti status 'Pending'?",
      "a": "Status 'Pending' berarti permintaan Anda sedang ditinjau oleh Admin/Laboran. Harap tunggu hingga status berubah menjadi 'Disetujui' sebelum mengambil barang."
    },
    {
      "q": "Bagaimana jika alat rusak/hilang?",
      "a": "Peminjam bertanggung jawab penuh atas alat. Segera lapor ke Admin Lab. Kerusakan akibat kelalaian akan dikenakan sanksi penggantian unit atau perbaikan."
    },
    {
      "q": "Bagaimana cara mengembalikan alat?",
      "a": "Bawa alat kembali ke Lab terkait. Kemudian buka aplikasi, masuk menu Transaksi > Pengembalian, dan tunjukkan kepada petugas untuk konfirmasi."
    },
    {
      "q": "Saya lupa password akun, bagaimana?",
      "a": "Pergi ke menu Profil > Ubah Profil. Di sana terdapat tombol 'Ganti Password'. Jika Anda tidak bisa login, hubungi Admin IT kampus untuk reset manual."
    },
    {
      "q": "Apakah ada denda keterlambatan?",
      "a": "Ya. Keterlambatan pengembalian tanpa konfirmasi akan menyebabkan akun Anda ditangguhkan sementara (suspend) dan tidak bisa meminjam alat lagi selama periode tertentu."
    },
    {
      "q": "Siapa yang harus dihubungi jika error?",
      "a": "Jika aplikasi mengalami kendala teknis, silakan hubungi Tim IT Support Labify di Gedung Administrasi Lt. 1 atau email ke support@labify.ac.id."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: Column(
        children: [
          // --- HEADER MODERN (Gradient Ungu) ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              // UBAH 1: CrossAxisAlignment jadi center agar teks di tengah
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                // UBAH 2: Bungkus tombol kembali dengan Align agar tetap di kiri
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
                
                const SizedBox(height: 10), // Jarak disesuaikan sedikit
                
                const Text(
                  "Pusat Bantuan",
                  textAlign: TextAlign.center, // Pastikan align text center
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 26, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Temukan jawaban atas masalahmu disini",
                  textAlign: TextAlign.center, // Pastikan align text center
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),

          // --- LIST FAQ (TIDAK BERUBAH) ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _faqData.length,
              itemBuilder: (context, index) {
                return _ModernFaqTile(
                  question: _faqData[index]['q']!,
                  answer: _faqData[index]['a']!,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Item FAQ Kustom (TIDAK BERUBAH)
class _ModernFaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final int index;

  const _ModernFaqTile({
    required this.question, 
    required this.answer,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8E78FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.question_answer_rounded, color: Color(0xFF764BA2), size: 20),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          children: [
            Divider(color: Colors.grey.withOpacity(0.1), height: 1),
            const SizedBox(height: 15),
            Text(
              answer,
              style: const TextStyle(
                color: Colors.black54, 
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
     ),
);
}
}