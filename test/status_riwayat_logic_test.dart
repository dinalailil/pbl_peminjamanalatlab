import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_peminjamanalatlab/logic/status_riwayat_logic.dart';

void main() {
  test('Status Dipinjam jika belum dikembalikan', () {
    expect(statusRiwayat(null), "Dipinjam");
  });

  test('Status Selesai jika sudah dikembalikan', () {
    expect(
      statusRiwayat(DateTime(2025, 1, 5)),
      "Selesai",
    );
  });
}
