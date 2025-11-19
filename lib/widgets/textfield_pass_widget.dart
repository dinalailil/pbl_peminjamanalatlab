import 'package:flutter/material.dart';

class TextfieldPasswordWidget extends StatelessWidget {
  final TextEditingController controller;
  
  const TextfieldPasswordWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.black87), // Hitam
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[800]),
        filled: true,
        fillColor: Colors.grey[100],
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
      validator: (value) {
        if (value == null || value.length < 6) return 'Min 6 karakter';
        return null;
      },
    );
  }
}