bool validasiPeminjaman(
  String namaPeminjam,
  DateTime tanggalPinjam,
  DateTime tanggalKembali,
) {
  if (namaPeminjam.isEmpty) return false;
  if (!tanggalKembali.isAfter(tanggalPinjam)) return false;
  return true;
}
