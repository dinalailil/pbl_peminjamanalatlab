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
              top: 160, // di bawah header
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

  // ================= CONTENT =================
  Widget _mainContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 30),
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
            _rowInfo("Nama Barang", pem['nama_barang'] ?? '-'),
            _rowInfo("Jumlah", pem['jumlah_pinjam'].toString()),
            _rowInfo("Tgl Peminjaman", _format(pem['tgl_pinjam'])),
            _rowInfo("Tgl Pengembalian", _format(pem['tgl_kembali'])),

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
    await FirebaseFirestore.instance
        .collection("peminjaman")
        .doc(widget.data.id)
        .update({
      "status": newStatus,
      "updated_at": FieldValue.serverTimestamp(),
    });

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

  // ================= UI HELPER =================
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
            Text("$l :"),
            Text(r, style: const TextStyle(fontWeight: FontWeight.w600)),
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