class MenuItem {
  final int id;
  //  ID unik untuk setiap menu (dipakai untuk membedakan item)

  final String name;
  //  Nama menu (contoh: Nasi Goreng, Bakso, dll)

  final String description;
  //  Deskripsi menu (penjelasan singkat tentang makanan)

  final double price;
  //  Harga menu (tipe double supaya bisa desimal kalau perlu)

  final String imageUrl;
  // Gambar menu (sementara pakai URL / emoji / asset path)

  final String category;
  //  Kategori menu (contoh: Nasi, Drink, Snack, dll)

  MenuItem({
    required this.id,

    //  Wajib diisi saat membuat object MenuItem
    required this.name,

    //  Nama wajib diisi
    required this.description,

    //  Deskripsi wajib diisi
    required this.price,

    //  Harga wajib diisi
    required this.imageUrl,

    //  Gambar wajib diisi
    required this.category,
    //  Kategori wajib diisi
  });
}
