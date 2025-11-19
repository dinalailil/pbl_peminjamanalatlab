import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNGSI REGISTER (Daftar Akun) ---
  Future<String?> register({
    required String email,
    required String password,
    required String nama,
  }) async {
    try {
      // 1. Buat akun di Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan biodata & Role ke Firestore
      // Ini inti dari tugas "Tim 1" agar punya role User/Admin
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nama': nama,
        'email': email,
        'role': 'user', // Default role mahasiswa
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Berhasil (tidak ada error)
    } on FirebaseAuthException catch (e) {
      return e.message; // Gagal, kembalikan pesan errornya
    }
  }

  // --- FUNGSI LOGIN ---
  Future<String?> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Berhasil
    } on FirebaseAuthException catch (e) {
      return e.message; // Gagal
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }
}