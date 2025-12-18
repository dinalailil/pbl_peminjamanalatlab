import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_peminjamanalatlab/logic/validasi_peminjaman_logic.dart';

void main() {
  test('Form valid jika data benar', () {
    expect(
      validasiPeminjaman(
        "Dina",
        DateTime(2025, 1, 1),
        DateTime(2025, 1, 2),
      ),
      true,
    );
  });

  test('Form tidak valid jika tanggal salah', () {
    expect(
      validasiPeminjaman(
        "Dina",
        DateTime(2025, 1, 2),
        DateTime(2025, 1, 1),
      ),
      false,
    );
  });
}
