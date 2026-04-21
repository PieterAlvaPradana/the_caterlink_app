import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/tenant.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';
import '../data/dummy_data.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final Tenant tenant;
  const MenuScreen({super.key, required this.tenant});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<CartItem> cartItems = [];
  String selectedCategory = 'All';
  final categories = [
    'All',
    'Nasi',
    'Soup',
    'Noodles',
    'Meat',
    'Vegetables',
    'Drinks',
  ];

  List<MenuItem> get filteredItems {
    if (selectedCategory == 'All') return dummyMenuItems;
    return dummyMenuItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.tenant.name,
          style: const TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () => _navigateToCart(),
                  child: Badge(
                    label: Text(
                      cartItems.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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

  Widget _buildMenuItem(MenuItem item) {
    CartItem? cartItem = cartItems.firstWhere(
      (ci) => ci.item.id == item.id,
      orElse: () => CartItem(item: item, quantity: 0),
    );
    int quantity = cartItem.quantity;

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              child: Text(item.imageUrl, style: const TextStyle(fontSize: 40)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 11, color: kTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    if (quantity == 0)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!cartItems.any((ci) => ci.item.id == item.id)) {
                              cartItems.add(CartItem(item: item, quantity: 1));
                            } else {
                              cartItems
                                  .firstWhere((ci) => ci.item.id == item.id)
                                  .quantity++;
                            }
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: setOpacity(kPrimaryColor, 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  cartItems
                                      .firstWhere((ci) => ci.item.id == item.id)
                                      .quantity--;
                                  if (cartItems
                                          .firstWhere(
                                            (ci) => ci.item.id == item.id,
                                          )
                                          .quantity ==
                                      0) {
                                    cartItems.removeWhere(
                                      (ci) => ci.item.id == item.id,
                                    );
                                  }
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Text(
                                  '-',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                () => cartItems
                                    .firstWhere((ci) => ci.item.id == item.id)
                                    .quantity++,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCart() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CartScreen(cartItems: cartItems),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
          ),
        )
        .then((_) => setState(() {}));
  }
}
