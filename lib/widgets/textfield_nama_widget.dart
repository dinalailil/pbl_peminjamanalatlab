import 'package:flutter/material.dart';

class TextfieldNamaWidget extends StatelessWidget {
  final TextEditingController controller;
  final Key? fieldKey;

  const TextfieldNamaWidget({
    super.key,
    required this.controller,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      // PENTING: Ubah warna teks jadi Hitam (biar kelihatan di background putih)
      style: const TextStyle(color: Colors.black87),

      decoration: InputDecoration(
        labelText: "Nama Lengkap", // Label kita ubah jadi Nama
        labelStyle: TextStyle(color: Colors.grey[600]),

        // Icon kita ubah jadi gambar Orang (Person)
        prefixIcon: Icon(Icons.person_outline, color: Colors.blue[800]),

        // Style di bawah ini sama persis dengan Email Widget baru
        filled: true,
        fillColor: Colors.grey[100], // Warna abu muda
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade800, width: 1.5),
        ),
      ),
      // Validasi: Cek apakah kosong
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nama tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
