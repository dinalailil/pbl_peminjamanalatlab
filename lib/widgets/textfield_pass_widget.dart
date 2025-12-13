import 'package:flutter/material.dart';

class TextfieldPasswordWidget extends StatefulWidget {
  final TextEditingController controller;
  
  const TextfieldPasswordWidget({super.key, required this.controller});

  @override
  State<TextfieldPasswordWidget> createState() => _TextfieldPasswordWidgetState();
}

class _TextfieldPasswordWidgetState extends State<TextfieldPasswordWidget> {
  // State untuk kontrol visibilitas password
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText, // Gunakan state ini
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[800]),
        
        // --- ICON MATA (Show/Hide) ---
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText; // Toggle state
            });
          },
        ),
        // -----------------------------

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