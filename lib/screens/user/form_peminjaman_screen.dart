import 'package:firebase_auth/firebase_auth.dart';
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

  TextEditingController namaController = TextEditingController();
  TextEditingController keperluanController = TextEditingController();

  int jumlahPinjam = 1;
  DateTime? tglPinjam;
  DateTime? tglKembali;
  bool loading = false;

  Future<void> pickDate(BuildContext context, bool isPinjam) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isPinjam) {
          tglPinjam = picked;
        } else {
          tglKembali = picked;
        }
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (tglPinjam == null || tglKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi tanggal pinjam & kembali")),
      );
      return;
    }

    setState(() => loading = true);

    final alatRef =
        FirebaseFirestore.instance.collection('alat').doc(widget.data.id);

    final pinjamRef = FirebaseFirestore.instance.collection("peminjaman");

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(alatRef);
        int stok = (snap['jumlah'] ?? 0) as int;

        if (stok < jumlahPinjam) {
          throw Exception("Stok tidak mencukupi!");
        }

        tx.update(alatRef, {
          "jumlah": stok - jumlahPinjam,
          "status": (stok - jumlahPinjam) == 0 ? "dipinjam" : "tersedia"
        });

        tx.set(pinjamRef.doc(), {
    "user_uid": FirebaseAuth.instance.currentUser!.uid,   // otomatis — tidak tampil di UI
  "nama_peminjam": namaController.text,
  "kode_barang": widget.data['kode'],
  "nama_barang": widget.data['nama'],
  "jumlah_pinjam": jumlahPinjam,        // tetap dipakai jika kamu punya field jumlah pinjam
  "keperluan": keperluanController.text, // jika form kamu punya ini
   "gambar": widget.data['gambar'] ?? "",

  "tgl_pinjam": Timestamp.fromDate(tglPinjam!),
  "tgl_kembali": Timestamp.fromDate(tglKembali!),
  "status": "diajukan",
  "created_at": FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Peminjaman diajukan!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.data.data() as Map<String, dynamic>;
    final warnaUngu = const Color(0xFF7A56FF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: warnaUngu,
        title: Text("Peminjaman (${map['kode']})",
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                map['nama'],
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              // =============================
              // NAMA PEMINJAM
              // =============================
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Peminjam",
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              // =============================
              // JUMLAH PINJAM (+ / -)
              // =============================
              const Text(
  "Jumlah Pinjam",
  style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 10),

Container(
  padding: const EdgeInsets.symmetric(horizontal: 15),
  decoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(color: Colors.grey.shade400, width: 1),
    ),
  ),
  child: Row(
    children: [
      // Tombol minus
      IconButton(
        onPressed: jumlahPinjam > 1
            ? () => setState(() => jumlahPinjam--)
            : null,
        icon: const Icon(Icons.remove_circle_outline),
      ),

      // Nilai jumlah pinjam
      Expanded(
        child: Text(
          jumlahPinjam.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tombol plus
      IconButton(
        onPressed: () => setState(() => jumlahPinjam++),
        icon: const Icon(Icons.add_circle_outline),
      ),
    ],
  ),
),

const SizedBox(height: 25),

              
              // =============================
              // TANGGAL PINJAM
              // =============================
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

              // =============================
              // TANGGAL KEMBALI
              // =============================
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

              const SizedBox(height: 35),

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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: warnaUngu,
                        foregroundColor: Colors.white,
                      ),
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
