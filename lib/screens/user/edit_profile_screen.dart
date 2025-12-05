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
  final _emailController = TextEditingController();
  final _passController = TextEditingController(); // Input Password Baru
  
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  File? _imageFile;        
  String? _oldPhotoBase64; 

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
          _emailController.text = user!.email ?? '';
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

  // --- FUNGSI SIMPAN (GABUNGAN UPDATE PROFIL & PASSWORD) ---
  Future<void> _saveAllChanges() async {
    setState(() => _isLoading = true);

    try {
      // 1. CEK APAKAH USER INGIN GANTI PASSWORD?
      if (_passController.text.isNotEmpty) {
        if (_passController.text.length < 6) {
          throw Exception("Password baru minimal 6 karakter.");
        }
        // Update Password ke Firebase Auth
        await user?.updatePassword(_passController.text);
      }

      // 2. PROSES FOTO (BASE64)
      String? base64ToSave = _oldPhotoBase64; 
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        base64ToSave = base64Encode(bytes);
        
        if (base64ToSave.length > 900000) {
             throw Exception("Ukuran foto terlalu besar. Pilih yang lebih kecil.");
        }
      }

      // 3. UPDATE DATA FIRESTORE (Nama & Foto)
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'nama': _namaController.text,
        'photo_base64': base64ToSave,
      });

      if (!mounted) return;
      
      // Jika sukses semua
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil & Data berhasil diperbarui!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context);

    } catch (e) {
      // Handle Error (Terutama jika User perlu Login Ulang untuk ganti password)
      String errorMessage = e.toString();
      if (errorMessage.contains("requires-recent-login")) {
        errorMessage = "Gagal Ganti Password: Mohon Logout dan Login ulang terlebih dahulu (Keamanan Google).";
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- AVATAR ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- INPUT NAMA ---
            _buildLabel("Ubah Nama Profile"),
            TextField(controller: _namaController, decoration: _inputDecoration("Masukkan nama")),
            const SizedBox(height: 20),
            

            // --- INPUT PASSWORD (BARU DI SINI) ---
            _buildLabel("Ubah Password"),
            TextField(
              controller: _passController,
              obscureText: true, // Sembunyikan text
              decoration: _inputDecoration("Isi jika ingin ganti password"),
            ),

            const SizedBox(height: 40),
            
            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAllChanges, // Panggil fungsi gabungan
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E78FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading 
                  ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text("Menyimpan...", style: TextStyle(color: Colors.white))
                    ])
                  : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint, 
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true, 
      fillColor: Colors.grey[200], 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
    );
  }
}