import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'seller_home_screen.dart';
import 'seller_orders_screen.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order.dart';
import 'scanner_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentIndex = 0;
  StreamSubscription? _orderSub;

  @override
  void initState() {
    super.initState();
    _listenForNewOrders();
  }

  void _listenForNewOrders() {
    final sellerId = FirebaseAuth.instance.currentUser!.uid;
    _orderSub = FirebaseFirestore.instance
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final order = OrderModel.fromFirestore(change.doc);
          // Show notification only if the order is very recent (less than 1 minute old)
          if (DateTime.now().difference(order.createdAt).inMinutes < 1) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🔔 Pesanan Baru Masuk dari ${order.userName}!'),
                  backgroundColor: kPrimaryColor,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  final List<Widget> _tabs = [
    const SellerHomeScreen(), // The Menu Management Screen
    const SellerOrdersScreen(), // The Incoming Orders Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              icon: Icons.restaurant_menu,
              label: 'Menu',
              index: 0,
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildTabItem(
              icon: Icons.receipt_long,
              label: 'Pesanan',
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? kPrimaryColor : kTextSecondary,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kPrimaryColor : kTextSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
