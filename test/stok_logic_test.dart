import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_peminjamanalatlab/logic/stok_logic.dart';

void main() {
  test('Menghitung sisa stok dengan benar', () {
    expect(hitungSisaStok(10, 3), 7);
  });

  test('Stok tidak boleh negatif', () {
    expect(hitungSisaStok(5, 5), 0);
  });
}
