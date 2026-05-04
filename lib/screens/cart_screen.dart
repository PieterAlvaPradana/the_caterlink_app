import 'package:flutter/material.dart'; 
// Import library Flutter untuk UI.

import '../constants/app_colors.dart'; 
// Import file warna aplikasi.

import '../models/cart_item.dart'; 
// Import model CartItem.

import 'payment_screen.dart'; 
// Import halaman pembayaran.

class CartScreen extends StatefulWidget {
// Widget stateful untuk halaman keranjang.

  final List<CartItem> cartItems;
// Menyimpan daftar item keranjang.

  const CartScreen({
    super.key,
    required this.cartItems,
  });
// Constructor dengan parameter wajib cartItems.

  @override
  State<CartScreen> createState() => _CartScreenState();
// Menghubungkan widget ke state.
}

class _CartScreenState extends State<CartScreen> {
// State class untuk CartScreen.

  late List<CartItem> _cartItems;
// Variabel lokal untuk mengelola isi keranjang.

  @override
  void initState() {
// Dipanggil pertama kali saat widget dibuat.

    super.initState();

    _cartItems = widget.cartItems;
// Menyalin data dari widget ke state lokal.
  }

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
// Getter untuk menghitung total harga semua item.

  @override
  Widget build(BuildContext context) {
// Method build utama.

    return Scaffold(
// Struktur dasar halaman.

      backgroundColor: kBackgroundColor,
// Background halaman.

      appBar: AppBar(
// AppBar atas.

        backgroundColor: kCardColor,
        elevation: 0,

        leading: IconButton(
// Tombol kembali.

          icon: const Icon(
            Icons.arrow_back,
            color: kTextPrimary,
          ),

          onPressed: () => Navigator.pop(context),
// Kembali ke halaman sebelumnya.
        ),

        title: const Text(
// Judul halaman.

          'Keranjang',

          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _cartItems.isEmpty
// Cek apakah keranjang kosong.

          ? Center(
// Jika kosong tampilkan ini.

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    '🛒',
                    style: TextStyle(fontSize: 60),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Keranjang kosong',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
            )

          : Column(
// Jika ada isi.

              children: [
                Expanded(
// List item mengambil ruang utama.

                  child: ListView.builder(
// List dinamis.

                    padding: const EdgeInsets.all(16),

                    itemCount: _cartItems.length,
// Jumlah item.

                    itemBuilder: (context, index) =>
                        _buildCartItem(_cartItems[index], index),
// Membangun tiap item.
                  ),
                ),

                Container(
// Footer total + tombol.

                  decoration: BoxDecoration(
                    color: kCardColor,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),

                  padding: const EdgeInsets.all(20),

                  child: SafeArea(
// Menyesuaikan area aman layar.

                    top: false,

                    child: Column(
                      children: [
                        Row(
// Baris total harga.

                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: [
                            const Text(
                              'Total Harga',

                              style: TextStyle(
                                fontSize: 16,
                                color: kTextSecondary,
                              ),
                            ),

                            Text(
                              'Rp${totalPrice.toStringAsFixed(0)}',
// Menampilkan total.

                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
// Tombol lanjut full width.

                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: () => _navigateToPayment(),
// Navigasi ke pembayaran.

                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,

                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),

                              elevation: 8,
                            ),

                            child: const Text(
                              'Lanjut',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(CartItem cartItem, int index) {
// Widget untuk satu item keranjang.

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
// Box gambar.

            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: setOpacity(kPrimaryColor, 0.1),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Center(
              child: Text(
                cartItem.item.imageUrl,
// Menampilkan emoji/gambar.

                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
// Area detail item.

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  cartItem.item.name,
// Nama item.

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Rp${cartItem.item.price.toStringAsFixed(0)}',
// Harga satuan.

                  style: const TextStyle(
                    fontSize: 13,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
// Kontrol jumlah.

            decoration: BoxDecoration(
              color: setOpacity(kPrimaryColor, 0.1),
              borderRadius: BorderRadius.circular(6),
            ),

            child: Row(
              children: [
                GestureDetector(
// Tombol minus.

                  onTap: () {
                    setState(() {
                      cartItem.quantity--;

                      if (cartItem.quantity == 0) {
                        _cartItems.removeAt(index);
                      }
// Jika 0 hapus item.
                    });
                  },

                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),

                    child: Text(
                      '-',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),

                Text(
                  cartItem.quantity.toString(),
// Jumlah item.

                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                GestureDetector(
// Tombol plus.

                  onTap: () => setState(() => cartItem.quantity++),

                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),

                    child: Text(
                      '+',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment() {
// Fungsi pindah ke halaman pembayaran.

    Navigator.of(context).push(
      PageRouteBuilder(
// Membuat animasi transisi.

        pageBuilder: (context, animation, secondaryAnimation) =>
            PaymentScreen(totalAmount: totalPrice),

        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                SlideTransition(
// Efek geser.

                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),

                  child: child,
                ),
      ),
    );
  }
}