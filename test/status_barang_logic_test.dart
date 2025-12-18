import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_peminjamanalatlab/logic/status_barang_logic.dart';

void main() {
  test('Status Tersedia jika stok lebih dari 0', () {
    expect(statusBarang(2), "Tersedia");
  });

  test('Status Dipinjam jika stok 0', () {
    expect(statusBarang(0), "Dipinjam");
  });
}
