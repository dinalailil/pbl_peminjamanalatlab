import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPermintaanScreen extends StatefulWidget {
  final QueryDocumentSnapshot data;

  const DetailPermintaanScreen({super.key, required this.data});

  @override
  State<DetailPermintaanScreen> createState() =>
      _DetailPermintaanScreenState();
}

class _DetailPermintaanScreenState extends State<DetailPermintaanScreen> {
  late Map<String, dynamic> pem;

  bool showOverlay = false;
  bool showCheck = false;

  @override
  void initState() {
    super.initState();
    pem = widget.data.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          // ================= MAIN CONTENT =================
          Column(
            children: [
              _buildHeader(context),
              Expanded(child: _mainContent(context)),
            ],
          ),

          // ================= OVERLAY SUCCESS =================
          if (showOverlay)
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: showCheck
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 120,
                          )
                        : const SizedBox(
                            width: 80,
                            height: 80,
                            child:
                                CircularProgressIndicator(strokeWidth: 6),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= CONTENT (DIMODIFIKASI) =================
  Widget _mainContent(BuildContext context) {
    // LOGIKA SAFE UNTUK FIELD LAB
    String infoLab = '-';
    if (pem['lab'] is List) {
      infoLab = (pem['lab'] as List).join(', ');
    } else if (pem['lab'] is String) {
      infoLab = pem['lab'];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Konfirmasi Peminjaman",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            _rowInfo("Nama", pem['nama_peminjam'] ?? '-'),
            _rowInfo("Kode Alat", pem['kode_barang'] ?? '-'),
            
            // --- MODIFIKASI: MENAMPILKAN LAB ---
            _rowInfo("Laboratorium", infoLab),
            
            _rowInfo("Nama Barang", pem['nama_barang'] ?? '-'),
            _rowInfo("Jumlah", pem['jumlah_pinjam'].toString()),
            _rowInfo("Tgl Peminjaman", _format(pem['tgl_pinjam'])),
            _rowInfo("Tgl Pengembalian", _format(pem['tgl_kembali'])),

            // --- MODIFIKASI: MENAMPILKAN KEPERLUAN ---
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(thickness: 1, color: Colors.grey),
            ),
            
            const Text(
              "Keperluan :",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 5),
            Text(
              (pem['keperluan'] ?? "").isEmpty ? 'Tidak ada keterangan' : pem['keperluan'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
            // ------------------------------------------

            const SizedBox(height: 30),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // ================= ACTION BUTTON =================
  Widget _buildActionButtons(BuildContext context) {
    final status = pem['status'];

    if (status == 'diajukan') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionButton(
            "Iya",
            Colors.green,
            () => _updateStatus(context, 'disetujui'),
          ),
          _actionButton(
            "Tidak",
            Colors.red,
            () => _updateStatus(context, 'ditolak'),
          ),
        ],
      );
    }

    if (status == 'disetujui') {
      return Center(
        child: _actionButton(
          "Konfirmasi Pengembalian",
          const Color(0xFF764BA2),
          () => _updateStatus(context, 'selesai'),
        ),
      );
    }

    return const SizedBox();
  }

  // ================= UPDATE STATUS =================
  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    // Update ke Firebase
    await FirebaseFirestore.instance
        .collection("peminjaman")
        .doc(widget.data.id)
        .update({
      "status": newStatus,
      "updated_at": FieldValue.serverTimestamp(),
    });

    // Opsional: Jika Anda ingin menambahkan logika pengurangan stok 
    // seperti kode Anda sebelumnya, Anda bisa menambahkannya di sini.
    // Namun untuk saat ini, saya biarkan sesuai versi Luthfi (hanya update status).

    if (!mounted) return;

    // ===== SETUJUI =====
    if (newStatus == 'disetujui') {
      Navigator.pop(context);
      return;
    }

    // ===== SELESAI (ANIMASI) =====
    if (newStatus == 'selesai') {
      setState(() => showOverlay = true);

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      setState(() => showCheck = true);

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      Navigator.pop(context, true);
      return;
    }

    // ===== TOLAK =====
    if (newStatus == 'ditolak') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil menolak!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  // ================= UI HELPER (DIMODIFIKASI AGAR TEXT TIDAK OVERFLOW) =================
  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _rowInfo(String l, String r) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$l :", style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 10), // Spasi
            Flexible( // Gunakan Flexible agar teks panjang turun ke bawah
              child: Text(
                r, 
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
              ),
            ),
          ],
        ),
      );

  String _format(Timestamp? t) =>
      t == null
          ? '-'
          : "${t.toDate().day}/${t.toDate().month}/${t.toDate().year}";

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      );

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E78FF), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                "Detail Permintaan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      );
}