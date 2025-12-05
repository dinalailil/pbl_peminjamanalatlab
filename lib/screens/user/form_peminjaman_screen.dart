import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final QueryDocumentSnapshot data;

  const FormPeminjamanScreen({super.key, required this.data});

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController idController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  DateTime? tglPinjam;
  DateTime? tglKembali;
  bool loading = false;

  Future<void> pickDate(BuildContext context, bool isPinjam) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi tanggal pinjam & kembali"))
      );
      return;
    }

    setState(() => loading = true);

    final itemRef =
        FirebaseFirestore.instance.collection('alat').doc(widget.data.id);

    final peminjamanRef =
        FirebaseFirestore.instance.collection("peminjaman");

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(itemRef);
        int current = (snap['jumlah'] ?? 0) as int;

        if (current <= 0) throw Exception("Stok habis!");

        tx.update(itemRef, {
          "jumlah": current - 1,
          "status": current - 1 == 0 ? "dipinjam" : "tersedia",
        });

        tx.set(peminjamanRef.doc(), {
          "id_peminjam": idController.text,
          "nama_peminjam": namaController.text,
          "kode_barang": widget.data['kode'],
          "nama_barang": widget.data['nama'],
          "tgl_pinjam": Timestamp.fromDate(tglPinjam!),
          "tgl_kembali": Timestamp.fromDate(tglKembali!),
          "status": "diajukan",
          "created_at": FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Peminjaman diajukan!"))
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e"))
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Formulir Peminjaman (${map['kode']})"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Nama Barang: ${map['nama']}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              TextFormField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: "ID Peminjam",
                ),
                validator: (v) => v!.isEmpty ? "Isi ID peminjam" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Peminjam",
                ),
                validator: (v) => v!.isEmpty ? "Isi nama peminjam" : null,
              ),

              const SizedBox(height: 20),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  tglPinjam == null
                      ? "Pilih Tanggal Pinjam"
                      : "Tanggal Pinjam: ${tglPinjam!.day}-${tglPinjam!.month}-${tglPinjam!.year}",
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => pickDate(context, true),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  tglKembali == null
                      ? "Pilih Tanggal Kembali"
                      : "Tanggal Kembali: ${tglKembali!.day}-${tglKembali!.month}-${tglKembali!.year}",
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () => pickDate(context, false),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      child: Text(loading ? "Mengirim..." : "Kirim"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
