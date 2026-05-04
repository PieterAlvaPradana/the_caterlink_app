class Tenant {
  final int id;
  //  ID unik untuk setiap tenant (warung / penjual)

  final String name;
  //  Nama tenant (contoh: Warung Mak Siti, Bakso Pak Joko)

  final String imageUrl;
  //  Gambar / icon tenant (bisa emoji, asset, atau URL)

  final double rating;
  //  Rating penilaian pengguna (contoh: 4.5, 4.8)

  final int reviews;
  //  Jumlah review dari user

  final double distance;
  //  Jarak tenant dari user (dalam km)

  final String estimatedTime;
  //  Estimasi waktu pengiriman (contoh: 10-15 menit)

  Tenant({
    required this.id,

    //  Wajib diisi saat membuat tenant
    required this.name,

    //  Nama tenant wajib diisi
    required this.imageUrl,

    //  Gambar tenant wajib diisi
    required this.rating,

    //  Rating wajib diisi
    required this.reviews,

    //  Jumlah review wajib diisi
    required this.distance,

    //  Jarak wajib diisi
    required this.estimatedTime,
    // Estimasi waktu wajib diisi
  });
}
