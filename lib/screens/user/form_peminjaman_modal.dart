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
  String status = ""; // <-- STATUS DITAMBAHKAN

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal pinjam & kembali"))
      );
      return;
    }

    setState(() => loading = true);

    final peminjamanRef = FirebaseFirestore.instance.collection('peminjaman');

    try {

      // SIMPAN DATA PEMINJAMAN
      await peminjamanRef.add({
        "id_peminjam": idController.text,
        "nama_peminjam": namaController.text,
        "kode_barang": widget.data['kode'],
        "nama_barang": widget.data['nama'],
        "tgl_pinjam": Timestamp.fromDate(tglPinjam!),
        "tgl_kembali": Timestamp.fromDate(tglKembali!),
        "status": "Diajukan",
        "created_at": FieldValue.serverTimestamp(),
      });

      setState(() {
        status = "Diajukan"; // <-- tampilkan status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Peminjaman berhasil diajukan"))
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${e.toString()}"))
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data() as Map<String, dynamic>;
    final kode = map['kode'] ?? "-";

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.95,
      minChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Formulir Peminjaman Alat",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),

                      Text("Kode $kode", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 20),

                      // FORM
                      TextFormField(
                        controller: idController,
                        decoration: const InputDecoration(labelText: "ID Peminjam"),
                        validator: (v) => v!.isEmpty ? "Isi ID" : null,
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(labelText: "Nama Peminjam"),
                        validator: (v) => v!.isEmpty ? "Isi Nama" : null,
                      ),

                      const SizedBox(height: 10),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          tglPinjam == null
                              ? "Tanggal Pinjam"
                              : "${tglPinjam!.day}/${tglPinjam!.month}/${tglPinjam!.year}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(context, true),
                      ),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          tglKembali == null
                              ? "Tanggal Kembali"
                              : "${tglKembali!.day}/${tglKembali!.month}/${tglKembali!.year}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => pickDate(context, false),
                      ),

                      const SizedBox(height: 10),

                      // === STATUS DI ATAS TOMBOL ===
                      if (status.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Status : $status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),

                      // BUTTONS
                      Row(
                        children: [

                          // BATAL
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                              ),
                              child: const Text("Batal"),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // KIRIM
                          Expanded(
                            child: ElevatedButton(
                              onPressed: loading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(loading ? "Loading..." : "Kirim"),
                            ),
                          ),
                        ],
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
