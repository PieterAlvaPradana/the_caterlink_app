import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/order.dart';

class AdminAllOrdersScreen extends StatefulWidget {
  const AdminAllOrdersScreen({super.key});

  @override
  State<AdminAllOrdersScreen> createState() => _AdminAllOrdersScreenState();
}

class _AdminAllOrdersScreenState extends State<AdminAllOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        title: const Text(
          'Semua Transaksi',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filters Area
          Container(
            color: kCardColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari berdasarkan ID/Nama/Seller...',
                      prefixIcon: Icon(Icons.search, color: kTextSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          _startDate == null ? 'Tanggal Mulai' : DateFormat('dd MMM yy').format(_startDate!),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) setState(() => _startDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          _endDate == null ? 'Tanggal Akhir' : DateFormat('dd MMM yy').format(_endDate!),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _endDate = DateTime(date.year, date.month, date.day, 23, 59, 59));
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_startDate != null || _endDate != null || _searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                      _searchQuery = '';
                    }),
                    child: const Text('Reset Filter'),
                  ),
                ],
              ],
            ),
          ),
          // Transactions list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collectionGroup('orders').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan memuat data.'));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada transaksi'));
                }

                var orders = snapshot.data!.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

                // Apply filters
                if (_startDate != null) {
                  orders = orders.where((o) => o.createdAt.isAfter(_startDate!)).toList();
                }
                if (_endDate != null) {
                  orders = orders.where((o) => o.createdAt.isBefore(_endDate!)).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  orders = orders.where((o) {
                    return o.id.toLowerCase().contains(_searchQuery) ||
                        o.userName.toLowerCase().contains(_searchQuery) ||
                        o.sellerName.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                final totalRevenue = orders.where((o) => o.status != 'cancelled').fold(0.0, (acc, o) => acc + o.totalPrice);
                final totalOrders = orders.length;

                return Column(
                  children: [
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Total Transaksi', style: TextStyle(color: kTextSecondary, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('$totalOrders', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Total Pendapatan', style: TextStyle(color: kTextSecondary, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(_formatRupiah(totalRevenue), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            color: kCardColor,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            shadowColor: Colors.black.withValues(alpha: 0.04),
                            child: ExpansionTile(
                              title: Text(
                                'Order ID: ${order.id.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text(
                                '${order.sellerName} ➔ ${order.userName}',
                                style: const TextStyle(fontSize: 12, color: kTextSecondary),
                              ),
                              trailing: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: order.status == 'done' ? kSuccessColor : Colors.orange,
                                ),
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  width: double.infinity,
                                  color: kBackgroundColor,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(height: 8),
                                      ...order.items.map((item) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Text('- ${item['quantity']}x ${item['name']} (${_formatRupiah((item['price'] ?? 0.0).toDouble())})'),
                                      )),
                                      const SizedBox(height: 8),
                                      Text('Total: ${_formatRupiah(order.totalPrice)}', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
                                      const SizedBox(height: 8),
                                      Text('Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt)}', style: const TextStyle(fontSize: 11, color: kTextSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
