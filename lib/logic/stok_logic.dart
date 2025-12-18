int hitungSisaStok(int total, int terpinjam) {
  if (terpinjam >= total) {
    return 0;
  }
  return total - terpinjam;
}
