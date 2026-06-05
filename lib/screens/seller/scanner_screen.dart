import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../data/order_repository.dart';
import '../../models/order.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final OrderRepository _orderRepository = OrderRepository();
  
  bool _isSearching = false;
  bool _hasSearched = false;
  List<OrderModel> _searchResults = [];
  String? _errorMessage;
  OrderModel? _selectedOrder;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  Future<void> _performSearch(String query) async {
    final queryText = query.trim();
    if (queryText.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _searchResults = [];
      _errorMessage = null;
      _selectedOrder = null;
    });

    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final queryLower = queryText.toLowerCase();

    try {
      List<OrderModel> results = [];

      // 1. Try search by Order ID if it looks like a Firestore Document ID (alphanumeric, long, no spaces/special chars)
      if (queryLower.length >= 12 && !queryLower.contains('@') && !queryLower.contains(' ')) {
        final order = await _orderRepository.getOrderById(queryText);
        if (order != null) {
          if (order.sellerId == sellerId) {
            results.add(order);
          } else {
            setState(() {
              _errorMessage = 'Pesanan ini milik kantin lain.';
              _isSearching = false;
            });
            return;
          }
        }
      }

      // 2. Search by Email or Name or Substring ID in seller's orders
      if (results.isEmpty) {
        QuerySnapshot querySnapshot;
        if (queryLower.contains('@')) {
          querySnapshot = await FirebaseFirestore.instance
              .collection('orders')
              .where('sellerId', isEqualTo: sellerId)
              .where('userEmail', isEqualTo: queryLower)
              .get();
        } else {
          querySnapshot = await FirebaseFirestore.instance
              .collection('orders')
              .where('sellerId', isEqualTo: sellerId)
              .get();
        }

        final allOrders = querySnapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc))
            .toList();

        if (queryLower.contains('@')) {
          results = allOrders;
        } else {
          // Filter locally for containing substring of name or ID
          results = allOrders.where((order) {
            final nameMatch = order.userName.toLowerCase().contains(queryLower);
            final emailMatch = order.userEmail.toLowerCase().contains(queryLower);
            final idMatch = order.id.toLowerCase().contains(queryLower);
            return nameMatch || emailMatch || idMatch;
          }).toList();
        }
      }

      setState(() {
        _searchResults = results;
        if (results.length == 1) {
          _selectedOrder = results.first;
        }
        if (results.isEmpty && _errorMessage == null) {
          _errorMessage = 'Pesanan tidak ditemukan. Periksa kembali ID atau Email yang Anda masukkan.';
        }
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _updateStatus(OrderModel order) async {
    setState(() => _isSearching = true);
    try {
      await _orderRepository.updateOrderStatus(order.id, 'done');
      
      // Update local state
      final updatedIndex = _searchResults.indexWhere((o) => o.id == order.id);
      if (updatedIndex != -1) {
        final updatedOrder = OrderModel(
          id: order.id,
          userId: order.userId,
          userName: order.userName,
          userEmail: order.userEmail,
          sellerId: order.sellerId,
          sellerName: order.sellerName,
          items: order.items,
          totalPrice: order.totalPrice,
          status: 'done',
          paymentMethod: order.paymentMethod,
          createdAt: order.createdAt,
        );
        setState(() {
          _searchResults[updatedIndex] = updatedOrder;
          _selectedOrder = updatedOrder;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Pesanan berhasil diselesaikan dan makanan diserahkan!'),
            backgroundColor: kSuccessColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal memperbarui status: $e'),
            backgroundColor: kDangerColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _simulatePrintPDF(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: kDangerColor),
            SizedBox(width: 10),
            Text('Ekspor Struk PDF', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Struk pesanan berhasil dicetak/diekspor.',
              style: TextStyle(fontWeight: FontWeight.w600, color: kTextPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID File: STRUK-${order.id.substring(0, 8).toUpperCase()}.pdf', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text('Pelanggan: ${order.userName}', style: const TextStyle(fontSize: 11)),
                  Text('Email: ${order.userEmail}', style: const TextStyle(fontSize: 11, color: kPrimaryColor, fontWeight: FontWeight.bold)),
                  Text('Total: ${_formatRupiah(order.totalPrice)}', style: const TextStyle(fontSize: 11)),
                  Text('Metode Bayar: ${order.paymentMethod.toUpperCase()}', style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.mark_email_read, color: kSuccessColor, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Salinan PDF struk digital telah dikirimkan ke email pembeli.',
                    style: TextStyle(fontSize: 11, color: kTextSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        title: const Text(
          'Cari & Selesaikan Pesanan',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: kTextPrimary),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: kCardColor,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari ID Pesanan / Email Pelanggan...',
                        hintStyle: const TextStyle(color: kTextSecondary, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: kTextSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: kTextSecondary, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (val) => setState(() {}),
                      onSubmitted: _performSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _performSearch(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text(
                    'Cari',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Main View Body
          Expanded(
            child: _buildMainBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainBody() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: kPrimaryColor),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
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
                  'Masukkan Detail Struk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ketikkan email pelanggan atau ID pesanan yang tertera pada struk PDF untuk memverifikasi pesanan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextSecondary, height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: kDangerColor, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text('Tidak ada pesanan ditemukan.', style: TextStyle(color: kTextSecondary)));
    }

    if (_selectedOrder != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildReceiptCard(_selectedOrder!),
      );
    }

    // Multiple orders found (when searching by email)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Ditemukan ${_searchResults.length} pesanan untuk kata kunci ini:',
            style: const TextStyle(fontWeight: FontWeight.bold, color: kTextSecondary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final order = _searchResults[index];
              return Card(
                color: kCardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('ID: ${order.id.substring(0, 8).toUpperCase()} - ${order.userName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Total: ${_formatRupiah(order.totalPrice)} • Status: ${order.status.toUpperCase()}', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    setState(() {
                      _selectedOrder = order;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptCard(OrderModel order) {
    final dateString = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);
    final isDone = order.status == 'done';

    return Column(
      children: [
        if (_searchResults.length > 1)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke hasil pencarian'),
              onPressed: () {
                setState(() {
                  _selectedOrder = null;
                });
              },
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'CATERLINK APP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: kPrimaryColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Struk Pengambilan Pesanan'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: kTextSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.black12, thickness: 1),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildReceiptRow('ID Pesanan', order.id.toUpperCase(), isBoldValue: true),
                    _buildReceiptRow('Tanggal', dateString),
                    _buildReceiptRow('Kantin', order.sellerName),
                    _buildReceiptRow('Pelanggan', order.userName),
                    _buildReceiptRow('Email Pelanggan', order.userEmail, isPrimaryValue: true),
                    _buildReceiptRow('Metode Bayar', order.paymentMethod.toUpperCase()),
                    const SizedBox(height: 12),
                    _buildDashedDivider(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Items Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextPrimary)),
                    Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kTextPrimary)),
                  ],
                ),
              ),

              // Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: order.items.map<Widget>((item) {
                    final String name = item['name'] ?? '';
                    final int qty = item['quantity'] ?? 1;
                    final double price = (item['price'] ?? 0.0).toDouble();
                    final String emoji = item['emoji'] ?? '🍔';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$emoji $qty x $name',
                              style: const TextStyle(fontSize: 13, color: kTextPrimary),
                            ),
                          ),
                          Text(
                            _formatRupiah(price * qty),
                            style: const TextStyle(fontSize: 13, color: kTextPrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Total
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildDashedDivider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL BAYAR',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: kTextPrimary),
                        ),
                        Text(
                          _formatRupiah(order.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code, size: 50, color: Colors.black87),
                          const SizedBox(height: 4),
                          Text(
                            '*CATERLINK-${order.id.substring(0, 8).toUpperCase()}*',
                            style: const TextStyle(fontSize: 10, color: kTextSecondary, letterSpacing: 1.5),
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
        const SizedBox(height: 24),
        
        // Action Buttons container
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _simulatePrintPDF(order),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Simpan PDF Struk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (!isDone) ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(order),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Ambil Pesanan (DONE)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSuccessColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (isDone) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSuccessColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kSuccessColor.withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: kSuccessColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Pesanan telah selesai diambil oleh pelanggan.',
                  style: TextStyle(color: kSuccessColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBoldValue = false, bool isPrimaryValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: kTextSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBoldValue || isPrimaryValue ? FontWeight.bold : FontWeight.normal,
                color: isPrimaryValue ? kPrimaryColor : kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.black26),
              ),
            );
          }),
        );
      },
    );
  }
}
