import 'package:flutter/material.dart';

class TextfieldEmailWidget extends StatelessWidget {
  final TextEditingController controller;

  const TextfieldEmailWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black87), // UBAH KE HITAM
      decoration: InputDecoration(
        labelText: "Email Address",
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.email_outlined, color: Colors.blue[800]), // Icon Biru
        filled: true,
        fillColor: Colors.grey[100], // Background abu sangat muda
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Hilangkan garis border default
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
      validator: (value) {
        if (value == null || !value.contains('@')) return 'Email tidak valid';
        return null;
      },
    );
  }
}