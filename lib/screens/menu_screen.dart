// Mengimpor package utama Flutter untuk UI
import 'package:flutter/material.dart';

// Mengimpor file konstanta warna aplikasi
import '../constants/app_colors.dart';

// Mengimpor model tenant
import '../models/tenant.dart';

// Mengimpor model item menu
import '../models/menu_item.dart';

// Mengimpor model item cart
import '../models/cart_item.dart';

// Mengimpor data dummy menu
import '../data/dummy_data.dart';

// Mengimpor halaman cart
import 'cart_screen.dart';


// Membuat halaman MenuScreen dengan StatefulWidget
class MenuScreen extends StatefulWidget {
  
  // Menyimpan data tenant yang dipilih
  final Tenant tenant;

  // Constructor untuk menerima tenant
  const MenuScreen({super.key, required this.tenant});

  // Membuat state untuk widget
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}


// State class untuk MenuScreen
class _MenuScreenState extends State<MenuScreen> {
  
  // Menyimpan daftar item di keranjang
  List<CartItem> cartItems = [];

  // Menyimpan kategori yang dipilih
  String selectedCategory = 'All';

  // Daftar kategori menu
  final categories = [
    'All',
    'Nasi',
    'Soup',
    'Noodles',
    'Meat',
    'Vegetables',
    'Drinks',
  ];

  // Getter untuk mengambil item sesuai kategori
  List<MenuItem> get filteredItems {
    if (selectedCategory == 'All') return dummyMenuItems;

    return dummyMenuItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  // Fungsi utama untuk membangun UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // Background halaman
      backgroundColor: kBackgroundColor,

      // AppBar atas
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,

        // Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),

        // Nama tenant
        title: Text(
          widget.tenant.name,
          style: const TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Action kanan atas
        actions: [
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),

              child: Center(
                child: GestureDetector(

                  // Klik icon cart
                  onTap: () => _navigateToCart(),

                  child: Badge(
                    label: Text(
                      cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),

                    child: Container(
                      width: 40,
                      height: 40,

                      decoration: BoxDecoration(
                        color: setOpacity(kPrimaryColor, 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: const Icon(
                        Icons.shopping_cart,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 20),
        ],
      ),

      // Isi halaman
      body: Column(
        children: [

          // List kategori horizontal
          SizedBox(
            height: 50,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,

              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8),

                child: GestureDetector(

                  // Pilih kategori
                  onTap: () =>
                      setState(() => selectedCategory = categories[index]),

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: selectedCategory == categories[index]
                          ? kPrimaryColor
                          : kCardColor,

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),

                    child: Center(
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: selectedCategory == categories[index]
                              ? Colors.white
                              : kTextPrimary,

                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grid menu
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),

              itemCount: filteredItems.length,

              itemBuilder: (context, index) =>
                  _buildMenuItem(filteredItems[index]),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi membuat kartu item menu
  Widget _buildMenuItem(MenuItem item) {
    
    // Cari item di cart
    CartItem? cartItem = cartItems.firstWhere(
      (ci) => ci.item.id == item.id,
      orElse: () => CartItem(item: item, quantity: 0),
    );

    int quantity = cartItem.quantity;

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Gambar/emoji item
          Container(
            width: double.infinity,
            height: 100,

            decoration: BoxDecoration(
              color: setOpacity(kPrimaryColor, 0.1),

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),

            child: Center(
              child: Text(
                item.imageUrl,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),

          // Detail item
          Padding(
            padding: const EdgeInsets.all(12),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Nama item
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                // Deskripsi
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kTextSecondary,
                  ),
                ),

                const SizedBox(height: 8),

                // Harga + tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Harga
                    Text(
                      'Rp${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),

                    // Jika belum ada di cart
                    if (quantity == 0)

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            cartItems.add(
                              CartItem(item: item, quantity: 1),
                            );
                          });
                        },

                        child: const Icon(Icons.add),
                      )

                    // Jika sudah ada
                    else

                      Row(
                        children: [

                          // Kurangi jumlah
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                quantity--;
                              });
                            },
                            child: const Text('-'),
                          ),

                          Text(quantity.toString()),

                          // Tambah jumlah
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                quantity++;
                              });
                            },
                            child: const Text('+'),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi navigasi ke cart
  void _navigateToCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartScreen(cartItems: cartItems),
      ),
    );
  }
}