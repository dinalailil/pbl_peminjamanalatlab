import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini untuk InputFormatter
import 'package:cloud_firestore/cloud_firestore.dart';

class FormAlatScreen extends StatefulWidget {
  final String? docId; 
  final Map<String, dynamic>? data; 
  final String namaLab; 

  const FormAlatScreen({
    super.key, 
    this.docId, 
    this.data, 
    required this.namaLab
  });

  @override
  State<FormAlatScreen> createState() => _FormAlatScreenState();
}

class _FormAlatScreenState extends State<FormAlatScreen> with SingleTickerProviderStateMixin {
  final Color primaryColorStart = const Color(0xFF8E78FF);
  final Color primaryColorEnd = const Color(0xFF764BA2);
  
  final _formKey = GlobalKey<FormState>();
  
  // Mode validasi: Awalnya disabled, baru aktif setelah user tekan simpan (biar ga merah semua pas awal)
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();
  final _stokController = TextEditingController();
  final _gambarController = TextEditingController();
  
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.forward();

    if (widget.docId != null && widget.data != null) {
      _namaController.text = widget.data!['nama'];
      _kodeController.text = widget.data!['kode'];
      _stokController.text = widget.data!['jumlah'].toString();
      _gambarController.text = widget.data!['gambar'] ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaController.dispose();
    _kodeController.dispose();
    _stokController.dispose();
    _gambarController.dispose();
    super.dispose();
  }

  // --- LOGIKA SIMPAN ---
  Future<void> _saveData() async {
    // Aktifkan validasi realtime jika user sudah mencoba submit tapi gagal
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      String nama = _namaController.text.trim();
      String kode = _kodeController.text.trim();
      int jumlah = int.tryParse(_stokController.text) ?? 0;
      String gambar = _gambarController.text.trim();
      String status = jumlah > 0 ? "Tersedia" : "Habis";

      // Validasi Tambahan Logika Bisnis (Opsional)
      if (jumlah < 0) {
        throw "Stok tidak boleh negatif";
      }

      if (widget.docId == null) {
        await FirebaseFirestore.instance.collection('alat').add({
          'nama': nama,
          'kode': kode,
          'jumlah': jumlah,
          'gambar': gambar,
          'status': status,
          'lab': [widget.namaLab], 
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('alat').doc(widget.docId).update({
          'nama': nama,
          'kode': kode,
          'jumlah': jumlah,
          'gambar': gambar,
          'status': status,
        });
      }

      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteData() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Barang?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm && widget.docId != null) {
      await FirebaseFirestore.instance.collection('alat').doc(widget.docId).delete();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barang dihapus"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.docId != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColorStart, primaryColorEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 1. FIXED HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        ),
                      ),
                      Text(
                        isEdit ? "Edit Barang" : "Tambah Baru",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      if (isEdit)
                        GestureDetector(
                          onTap: _deleteData,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                          ),
                        )
                      else
                        const SizedBox(width: 44), 
                    ],
                  ),
                ),

                // 2. SCROLLABLE FORM
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F7FE),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _autovalidateMode, // Validasi pintar
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  // --- Image Preview ---
                                  Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 120, height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                                          ),
                                          child: _gambarController.text.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: Image.network(
                                                    _gambarController.text, 
                                                    fit: BoxFit.cover, 
                                                    errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.grey)
                                                  ),
                                                )
                                              : Icon(Icons.image_search_rounded, size: 40, color: primaryColorStart.withOpacity(0.5)),
                                        ),
                                        const SizedBox(height: 10),
                                        Text("Preview Foto", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // --- Input Fields ---
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 20)],
                                    ),
                                    child: Column(
                                      children: [
                                        _buildTextField(
                                          _namaController, 
                                          "Nama Barang", 
                                          Icons.inventory_2_outlined,
                                          validator: (val) {
                                            if (val == null || val.isEmpty) return "Nama barang wajib diisi";
                                            if (val.length < 3) return "Minimal 3 karakter";
                                            return null;
                                          }
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            Expanded(child: _buildTextField(
                                              _kodeController, 
                                              "Kode", 
                                              Icons.qr_code,
                                              validator: (val) => (val == null || val.isEmpty) ? "Wajib diisi" : null
                                            )),
                                            const SizedBox(width: 15),
                                            Expanded(child: _buildTextField(
                                              _stokController, 
                                              "Stok", 
                                              Icons.numbers, 
                                              isNumber: true,
                                              validator: (val) {
                                                if (val == null || val.isEmpty) return "Wajib";
                                                if (int.tryParse(val) == null) return "Angka";
                                                return null;
                                              }
                                            )),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        _buildTextField(
                                          _gambarController, 
                                          "URL Gambar", 
                                          Icons.link_rounded, 
                                          isUrl: true, 
                                          onChanged: (val) => setState(() {}),
                                          validator: (val) {
                                            if (val == null || val.isEmpty) return "URL wajib diisi";
                                            if (!val.startsWith('http')) return "Link tidak valid (harus http/https)";
                                            return null;
                                          }
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // --- Tombol Simpan ---
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _saveData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [primaryColorStart, primaryColorEnd]),
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [BoxShadow(color: primaryColorStart.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: _isLoading 
                                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                              : Text(isEdit ? "Simpan Perubahan" : "Tambahkan Sekarang", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 50),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget TextField yang Diperbarui dengan Validasi
  Widget _buildTextField(
    TextEditingController controller, 
    String hint, 
    IconData icon, 
    {
      bool isNumber = false, 
      bool isUrl = false, 
      Function(String)? onChanged,
      String? Function(String?)? validator // Parameter Validator
    }
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      validator: validator, // Pasang validator disini
      
      // Input Formatters (Agar stok cuma bisa angka)
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
        prefixIcon: Icon(icon, color: isUrl ? Colors.blue : const Color(0xFF8E78FF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8E78FF), width: 1.5)),
        
        // Style Error (Merah saat salah)
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade200, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11, color: Colors.red), // Font error kecil rapi
        
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}