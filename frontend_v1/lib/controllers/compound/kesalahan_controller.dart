class KesalahanController {
  static String getPerintahFromDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Perintah Tidak Dikenalpasti';
    }

    final text = description.trim().toUpperCase();

    // ===== Check one by one =====
    if (text.contains('GAGAL MEMPAMERKAN KUPON LETAK KERETA YANG SAH')) {
      return 'Perintah 30(a)';
    } else if (text.contains('MEMPAMERKAN KUPON LETAK KERETA YANG TAMAT TEMPOH')) {
      return 'Perintah 30(b)';
    } else if (text.contains('MEMPAMERKAN KUPON LETAK KERETA YANG TIDAK DIKENALPASTI')) {
      return 'Perintah 30(c)';
    } else if (text.contains('MENGHILANGKAN KUPON TEMPAT LETAK KERETA TERKAWAL')) {
      return 'Perintah 33';
    } else if (text.contains('HALANGAN DALAM PETAK LETAK KERETA')) {
      return 'Perintah 39(1)';
    } else if (text.contains('MELETAK KENDERAAN MOTOR SELAIN DI TEMPAT LETAK KERETA')) {
      return 'Perintah 4';
    } else if (text.contains('BERNIAGA DALAM PETAK KERETA TANPA KEBENARAN')) {
      return 'Perintah 44';
    } else if (text.contains('MEMBAIKI KENDERAAN DALAM PETAK LETAK KERETA')) {
      return 'Perintah 45';
    } else if (text.contains('MENCUCI') ||
        text.contains('MEMBASUH KENDERAAN DALAM PETAK')) {
      return 'Perintah 46';
    } else if (text.contains('TUJUAN PENJUALAN DALAM PETAK KERETA')) {
      return 'Perintah 48';
    } else if (text.contains('MEMBUANG') ||
        text.contains('MENGALIH RESIT') ||
        text.contains('KOMPAUN')) {
      return 'Perintah 49';
    } else if (text.contains('GAGAL MEMATUHI SYARAT-SYARAT TEMPAT LETAK KERETA')) {
      return 'Perintah 5';
    } else if (text.contains('PETAK KHAS')) {
      return 'Perintah 51';
    } else if (text.contains('SEBAHAGIAN SAHAJA DALAM PETAK KERETA')) {
      return 'Perintah 7(1)a';
    } else if (text.contains('TANPA MENGIKUT ARAH LALU LINTAS')) {
      return 'Perintah 7(1)b';
    } else if (text.contains('CARA MELINTANG')) {
      return 'Perintah 7(1)c';
    } else if (text.contains('MENGGUNAKAN DUA PETAK KERETA')) {
      return 'Perintah 7(1)d';
    } else if (text.contains('MASA KAWALAN TANPA MEMBAYAR BAYARAN LETAK KERETA')) {
      return 'Perintah 8';
    }

    return 'Perintah Tidak Dikenalpasti';
  }


  static String getDetailFromPerintah(String perintah) {
  switch (perintah) {
    case 'Perintah 30(a)':
      return 'Gagal mempamerkan kupon letak kereta yang sah';
    case 'Perintah 30(b)':
      return 'Mempamerkan kupon letak kereta yang tamat tempoh';
    case 'Perintah 30(c)':
      return 'Mempamerkan kupon yang tidak dikenalpasti';
    case 'Perintah 33':
      return 'Menghilangkan kupon tempat letak kereta terkawal';
    case 'Perintah 39(1)':
      return 'Halangan dalam petak letak kereta';
    case 'Perintah 4':
      return 'Meletak kenderaan selain di tempat letak kereta';
    case 'Perintah 44':
      return 'Berniaga dalam petak kereta tanpa kebenaran';
    case 'Perintah 45':
      return 'Membaiki kenderaan dalam petak letak kereta';
    case 'Perintah 46':
      return 'Mencuci kenderaan dalam petak letak kereta';
    case 'Perintah 48':
      return 'Tujuan penjualan dalam petak kereta';
    case 'Perintah 49':
      return 'Membuang atau mengalih resit kompaun';
    case 'Perintah 5':
      return 'Gagal mematuhi syarat tempat letak kereta';
    case 'Perintah 51':
      return 'Menggunakan petak khas tanpa kebenaran';
    case 'Perintah 7(1)a':
      return 'Sebahagian sahaja dalam petak kereta';
    case 'Perintah 7(1)b':
      return 'Tidak mengikut arah lalu lintas';
    case 'Perintah 7(1)c':
      return 'Meletak secara melintang';
    case 'Perintah 7(1)d':
      return 'Menggunakan dua petak kereta';
    case 'Perintah 8':
      return 'Tidak membayar dalam masa kawalan';
    default:
      return '-';
  }
}

}
