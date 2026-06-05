import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../models/order.dart';
import '../main_navigation_shell.dart';

class OrderReceiptScreen extends StatefulWidget {
  final String orderId;

  const OrderReceiptScreen({super.key, required this.orderId});

  @override
  State<OrderReceiptScreen> createState() => _OrderReceiptScreenState();
}

class _OrderReceiptScreenState extends State<OrderReceiptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Tunai';
      case 'card':
        return 'Kartu Debit/Kredit';
      case 'transfer':
        return 'Transfer Bank';
      case 'ewallet':
        return 'E-Wallet';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: kDangerColor, size: 48),
                  const SizedBox(height: 16),
                  const Text('Pesanan tidak ditemukan'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _backToHome,
                    child: const Text('Kembali ke Beranda'),
                  ),
                ],
              ),
            );
          }

          final order = OrderModel.fromFirestore(snapshot.data!);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Success animation
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: kSuccessColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: kSuccessColor,
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pembayaran Berhasil!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tunjukkan struk ini saat pengambilan pesanan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: kTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ==========================================
                      // RECEIPT / STRUK PDF-STYLE
                      // ==========================================
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [kPrimaryColor, kAccentColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    '🍽️ CaterLink',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'STRUK PEMBAYARAN',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const SizedBox.shrink(),
                                ],
                              ),
                            ),

                            // Body
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Order ID
                                  _buildReceiptRow(
                                    'No. Pesanan',
                                    '#${widget.orderId.substring(0, 8).toUpperCase()}',
                                  ),
                                  const SizedBox(height: 8),
                                  const SizedBox.shrink(),
                                  // Date
                                  _buildReceiptRow(
                                    'Tanggal',
                                    DateFormat('dd MMM yyyy, HH:mm')
                                        .format(order.createdAt),
                                  ),
                                  const SizedBox(height: 8),
                                  // Tenant/Seller
                                  _buildReceiptRow(
                                    'Kantin',
                                    order.sellerName,
                                  ),
                                  const SizedBox(height: 8),
                                  // Payment method
                                  _buildReceiptRow(
                                    'Pembayaran',
                                    _getPaymentMethodName(order.paymentMethod),
                                  ),

                                  const SizedBox(height: 16),
                                  // Dashed divider
                                  _buildDashedDivider(),
                                  const SizedBox(height: 12),

                                  // Customer Info
                                  const Text(
                                    'INFORMASI PEMESAN',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: kTextSecondary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildReceiptRow('Nama', order.userName),
                                  const SizedBox(height: 4),
                                  _buildReceiptRow('Email', order.userEmail),

                                  const SizedBox(height: 16),
                                  _buildDashedDivider(),
                                  const SizedBox(height: 12),

                                  // Items
                                  const Text(
                                    'DETAIL PESANAN',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: kTextSecondary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...order.items.map((item) {
                                    final name = item['name'] ?? '';
                                    final emoji = item['emoji'] ?? '🍽️';
                                    final qty = item['quantity'] ?? 1;
                                    final price =
                                        (item['price'] ?? 0.0).toDouble();
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(emoji,
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: kTextPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  '${qty}x @ ${_formatRupiah(price)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: kTextSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            _formatRupiah(price * qty),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: kTextPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  const SizedBox(height: 8),
                                  _buildDashedDivider(),
                                  const SizedBox(height: 12),

                                  // Total
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TOTAL',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: kTextPrimary,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah(order.totalPrice),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),
                                  _buildDashedDivider(),
                                  const SizedBox(height: 16),

                                  // Footer note
                                  Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: kPrimaryColor
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'ID: ${widget.orderId}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: kPrimaryColor,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Tunjukkan struk ini kepada tenant\nsaat mengambil pesanan Anda',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: kTextSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Terima kasih! 🙏',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: kTextPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom button
              Container(
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
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _backToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 6.0;
        final dashSpace = 4.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (index) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: kTextSecondary.withValues(alpha: 0.3),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  void _backToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigationShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
      (route) => false,
    );
  }
}
