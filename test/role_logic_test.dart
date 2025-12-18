import 'package:flutter_test/flutter_test.dart';
import 'package:pbl_peminjamanalatlab/logic/role_logic.dart';

void main() {
  test('Admin diarahkan ke halaman admin', () {
    expect(halamanByRole("admin"), "admin_home");
  });

  test('User diarahkan ke halaman user', () {
    expect(halamanByRole("user"), "user_home");
  });
}
