import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController(); // Controller Email (Read only)
  final _passController = TextEditingController();
  
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  // --- STATE BARU: UNTUK MATA PASSWORD ---
  bool _isPasswordVisible = false; 

  File? _imageFile;        
  String? _oldPhotoBase64; 

  // Warna Tema
  final Color primaryColorStart = const Color(0xFF8E78FF);
  final Color primaryColorEnd = const Color(0xFF764BA2);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          _namaController.text = doc['nama'] ?? '';
          _emailController.text = user!.email ?? ''; // Load email
          if (doc.data()!.containsKey('photo_base64')) {
            _oldPhotoBase64 = doc['photo_base64'];
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 30, 
      maxWidth: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); 
      });
    }
  }

  Future<void> _saveAllChanges() async {
    setState(() => _isLoading = true);

    try {
      // 1. Update Password (Jika diisi)
      if (_passController.text.isNotEmpty) {
        if (_passController.text.length < 6) {
          throw Exception("Password baru minimal 6 karakter.");
        }
        await user?.updatePassword(_passController.text);
      }

      // 2. Proses Foto (Base64)
      String? base64ToSave = _oldPhotoBase64; 
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        base64ToSave = base64Encode(bytes);
        if (base64ToSave.length > 900000) {
             throw Exception("Ukuran foto terlalu besar. Pilih yang lebih kecil.");
        }
      }

      // 3. Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'nama': _namaController.text,
        'photo_base64': base64ToSave,
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Color.fromARGB(255, 240, 136, 238))
      );
      Navigator.pop(context);

    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains("requires-recent-login")) {
        errorMessage = "Gagal: Mohon Logout dan Login ulang dulu untuk ganti password.";
      } else if (errorMessage.contains("Exception:")) {
        errorMessage = errorMessage.replaceAll("Exception: ", "");
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 4))
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // appbar: null, // Hapus AppBar agar header kita bisa full ke atas
      
      body: SingleChildScrollView(
        // Hapus padding di sini agar header menempel ke tepi layar
        child: Column(
          children: [
            // --- HEADER STACK FULL SCREEN ---
            SizedBox(
              height: 260, 
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Background Gradient (Full ke Atas)
                  Positioned(
                    top: 0, // Tempel ke atas
                    left: 0,
                    right: 0,
                    height: 200, // Tinggi area ungu
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColorStart, primaryColorEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),

                  // 2. Tombol Back & Judul (Pakai SafeArea hanya untuk konten ini)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            ),
                            const Expanded(
                              child: Text(
                                "Edit Profil",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white, 
                                  fontSize: 22, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5
                                ),
                              ),
                            ),
                            const SizedBox(width: 48), // Penyeimbang
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Avatar Overlap
                  Positioned(
                    bottom: 0,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1), 
                                blurRadius: 15, 
                                offset: const Offset(0, 5)
                              )
                            ],
                            image: _imageFile != null
                                ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                                : (_oldPhotoBase64 != null 
                                    ? DecorationImage(image: MemoryImage(base64Decode(_oldPhotoBase64!)), fit: BoxFit.cover)
                                    : null) 
                          ),
                          child: (_imageFile == null && _oldPhotoBase64 == null)
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                        
                        // Tombol Kamera
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.amber, 
                                shape: BoxShape.circle
                              ),
                              child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- FORM SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama Lengkap"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextField(
                      controller: _namaController,
                      decoration: _inputDecoration("Masukkan nama anda", Icons.person_outline),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // --- FIELD PASSWORD DENGAN MATA ---
                  _buildLabel("Ubah Password "),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextField(
                      controller: _passController,
                      obscureText: !_isPasswordVisible, // Dinamis: Sembunyi/Muncul
                      decoration: _inputDecoration(
                        "Isi untuk ganti password", 
                        Icons.lock_outline,
                        // Ikon Mata di Kanan
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isMenuOpen() ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle status
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // TOMBOL SIMPAN
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primaryColorStart, primaryColorEnd]),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: primaryColorStart.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAllChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk cek kondisi icon mata (agar kodingan di atas rapi)
  bool _isMenuOpen() => _isPasswordVisible;

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 5),
      child: Text(
        text, 
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 14)
      ),
    );
  }

  // Modified Helper: Bisa menerima suffixIcon (tombol mata)
  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primaryColorStart.withOpacity(0.7)),
      suffixIcon: suffixIcon, // Tambahan untuk tombol mata
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: Colors.transparent, // Transparan karena container luarnya sudah putih
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}