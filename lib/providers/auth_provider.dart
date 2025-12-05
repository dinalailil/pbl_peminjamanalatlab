import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// Import kode login role-based yang sudah kita buat
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  // Service lama kita tetap dipakai untuk logic Firebase
  final AuthService _service = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- LOGIC BARU UNTUK UI BARU ---
  
  // 1. Status untuk toggle (true = Halaman Login, false = Halaman Register)
  bool _isLogin = true; 
  bool get isLogin => _isLogin;

  // 2. Status loading (sama seperti sebelumnya)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 3. GlobalKey untuk validasi Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> get formKey => _formKey;

  // 4. Controller untuk text fields
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  TextEditingController get namaCtrl => _namaCtrl;
  TextEditingController get emailCtrl => _emailCtrl;
  TextEditingController get passCtrl => _passCtrl;

  // 5. Fungsi untuk toggle UI
  void toggleLogin() {
    _isLogin = !_isLogin;
    // Bersihkan field saat ganti mode
    _namaCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();
    notifyListeners();
  }

  // 6. Fungsi Submit (Dipanggil oleh Tombol)
  Future<void> submit(BuildContext context) async {
    // Validasi form dulu
    if (!_formKey.currentState!.validate()) {
      return; // Jika form tidak valid, stop
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_isLogin) {
        // --- PROSES LOGIN (Sama seperti kode lama kita) ---
        await _handleLogin(context, _emailCtrl.text, _passCtrl.text);
      } else {
        // --- PROSES REGISTER (Sama seperti kode lama kita) ---
        await _handleRegister(context, _namaCtrl.text, _emailCtrl.text, _passCtrl.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Helper Functions (Logika lama kita pindah ke sini) ---

  Future<void> _handleRegister(BuildContext context, String nama, String email, String password) async {
    String? error = await _service.register(
      email: email, 
      password: password, 
      nama: nama
    );

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Color.fromARGB(255, 175, 76, 160)),
      );
      toggleLogin(); // Balik ke halaman login setelah sukses register
    } else {
      throw Exception(error); // Lempar error
    }
  }

  Future<void> _handleLogin(BuildContext context, String email, String password) async {
    String? error = await _service.login(email: email, password: password);

    if (error != null) {
      throw Exception(error); // Lempar error jika auth gagal
    }

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (doc.exists) {
        String role = doc.get('role');
        if (role == 'admin') {
           Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
           Navigator.pushReplacementNamed(context, '/user-dashboard');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Berhasil!"), backgroundColor: Color.fromARGB(255, 210, 128, 231)),
        );
      } else {
        throw Exception("Data user tidak ditemukan di Database!");
      }
    }
  }

  // Override dispose untuk bersihkan controller
  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}