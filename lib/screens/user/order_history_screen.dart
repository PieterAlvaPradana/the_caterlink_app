import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../data/order_repository.dart';
import '../../models/order.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return kSuccessColor;
      case 'cancelled':
        return kDangerColor;
      case 'processing':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: OrderRepository().getUserOrders(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: kDangerColor, size: 48),
                  const SizedBox(height: 16),
                  Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: kTextSecondary)),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.receipt_long, color: kPrimaryColor, size: 48),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum Ada Pesanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Anda belum melakukan pemesanan makanan.',
                    style: TextStyle(color: kTextSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final dateString = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);
              final statusColor = _getStatusColor(order.status);

              return Card(
                color: kCardColor,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    childrenPadding: const EdgeInsets.all(20),
                    backgroundColor: kCardColor,
                    collapsedBackgroundColor: kCardColor,
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.sellerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateString,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Total: ${_formatRupiah(order.totalPrice)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Item:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...order.items.map((item) {
                              final name = item['name'] ?? '';
                              final qty = item['quantity'] ?? 1;
                              final price = (item['price'] ?? 0.0).toDouble();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$qty x $name',
                                      style: const TextStyle(fontSize: 13, color: kTextPrimary),
                                    ),
                                    Text(
                                      _formatRupiah(price * qty),
                                      style: const TextStyle(fontSize: 13, color: kTextSecondary),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pembayaran',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: kTextPrimary,
                                  ),
                                ),
                                Text(
                                  _formatRupiah(order.totalPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ID Pesanan: ${order.id}',
                              style: const TextStyle(fontSize: 10, color: kTextSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
