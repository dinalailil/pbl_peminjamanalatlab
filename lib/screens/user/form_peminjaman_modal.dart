// form_peminjaman_modal.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPeminjamanModal extends StatefulWidget {
  final QueryDocumentSnapshot data;

  const FormPeminjamanModal({Key? key, required this.data}) : super(key: key);

  @override
  State<FormPeminjamanModal> createState() => _FormPeminjamanModalState();
}

class _FormPeminjamanModalState extends State<FormPeminjamanModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController idController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  DateTime? tglPinjam;
  DateTime? tglKembali;
  bool loading = false;

  Future<void> pickDate(BuildContext c, bool isPinjam) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: c,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isPinjam) tglPinjam = picked;
      else tglKembali = picked;
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (tglPinjam == null || tglKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih tanggal pinjam & kembali")));
      return;
    }

    setState(() => loading = true);

    final alatRef = FirebaseFirestore.instance.collection('alat').doc(widget.data.id);
    final peminjamanRef = FirebaseFirestore.instance.collection('peminjaman');

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snap = await transaction.get(alatRef);
        final map = snap.data() as Map<String, dynamic>? ?? {};
        final curr = (map['jumlah'] is num) ? (map['jumlah'] as num).toInt() : 0;

        if (curr <= 0) {
          throw Exception("Stok tidak cukup");
        }

        final newJumlah = curr - 1;

        // buat doc peminjaman (sementara inside transaction)
        final peminjamanDoc = peminjamanRef.doc();
        transaction.set(peminjamanDoc, {
          "id_peminjam": idController.text,
          "nama_peminjam": namaController.text,
          "kode_barang": widget.data['kode'],
          "nama_barang": widget.data['nama'],
          "tgl_pinjam": Timestamp.fromDate(tglPinjam!),
          "tgl_kembali": Timestamp.fromDate(tglKembali!),
          "status": "Menunggu Konfirmasi",
          "created_at": FieldValue.serverTimestamp(),
        });

        // update stok alat
        transaction.update(alatRef, {
          "jumlah": newJumlah,
          "status": newJumlah == 0 ? "Dipinjam" : "Tersedia",
        });
      });

      // selesai
      if (mounted) {
        Navigator.of(context).pop(); // close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil mengajukan peminjaman")));
      }
    } catch (e) {
      // error handling
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data() as Map<String, dynamic>;
    final kode = map['kode'] ?? "-";

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(18),
                width: MediaQuery.of(context).size.width * 0.94,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Formulir Peminjaman Alat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Kode $kode", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: idController,
                        decoration: const InputDecoration(labelText: "ID Peminjam"),
                        validator: (v) => v == null || v.isEmpty ? "Isi ID" : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(labelText: "Nama Peminjam"),
                        validator: (v) => v == null || v.isEmpty ? "Isi nama" : null,
                      ),
                      const SizedBox(height: 8),

                      // tanggal pinjam
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tglPinjam == null ? "Tanggal Pinjam" : "${tglPinjam!.day}-${tglPinjam!.month}-${tglPinjam!.year}"),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(context, true),
                      ),
                      const SizedBox(height: 6),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(tglKembali == null ? "Tanggal Kembali" : "${tglKembali!.day}-${tglKembali!.month}-${tglKembali!.year}"),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(context, false),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : submit,
                          child: Text(loading ? "Loading..." : "Kirim"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
