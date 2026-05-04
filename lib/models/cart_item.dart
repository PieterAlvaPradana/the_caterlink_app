import 'menu_item.dart'; // 🔥 Mengambil model MenuItem untuk digunakan di CartItem

class CartItem {
  final MenuItem item; 
  // 🔥 Menyimpan data menu yang dipilih (contoh: Nasi Goreng, Bakso, dll)

  int quantity;
  // 🔥 Menyimpan jumlah item yang dibeli (bisa berubah saat di cart)

  CartItem({required this.item, this.quantity = 1});
  // 🔥 Constructor CartItem
  // - item wajib diisi (menu yang dipilih)
  // - quantity default = 1 jika tidak diisi

  double get totalPrice => item.price * quantity;
  // 🔥 Getter untuk menghitung total harga
  // Rumus: harga menu × jumlah quantity
  // Contoh: 20.000 × 2 = 40.000
}