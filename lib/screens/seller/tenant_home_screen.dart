import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import 'scanner_screen.dart';

class TenantHomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToMenu;
  final VoidCallback? onNavigateToOrders;

  const TenantHomeScreen({
    super.key,
    this.onNavigateToMenu,
    this.onNavigateToOrders,
  });

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,
        title: const Text(
          'Tenant Dashboard',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('sellerId', isEqualTo: sellerId)
            .snapshots(),
        builder: (context, snapshot) {
          final orders = snapshot.data?.docs ?? [];
          final activeOrdersCount = orders.where((doc) {
            final status = (doc.data() as Map<String, dynamic>)['status'] as String? ?? 'pending';
            return status == 'pending' || status == 'processing';
          }).length;

          final completedOrders = orders.where((doc) {
            final status = (doc.data() as Map<String, dynamic>)['status'] as String? ?? '';
            return status == 'done';
          });

          final totalEarnings = completedOrders.fold(0.0, (acc, doc) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['totalPrice'] ?? 0.0).toDouble();
            return acc + price;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimaryColor, kAccentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang Kembali!',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mari layani pelanggan Anda hari ini.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _formatRupiah(totalEarnings),
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Total Pendapatan Selesai',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        title: 'Pesanan Aktif',
                        value: '$activeOrdersCount',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Pesanan Selesai',
                        value: '${completedOrders.length}',
                        color: kSuccessColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Aksi Cepat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextPrimary),
                ),
                const SizedBox(height: 12),
                // Quick actions list
                _buildQuickAction(
                  context: context,
                  icon: Icons.receipt_long,
                  title: 'Cek & Selesaikan Pesanan',
                  subtitle: 'Cari pesanan berdasarkan ID atau Email',
                  color: kPrimaryColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScannerScreen()),
                    );
                  },
                ),
                _buildQuickAction(
                  context: context,
                  icon: Icons.restaurant_menu,
                  title: 'Kelola Menu Makanan',
                  subtitle: 'Tambah atau ubah menu kantin Anda',
                  color: kAccentColor,
                  onTap: onNavigateToMenu,
                ),
                _buildQuickAction(
                  context: context,
                  icon: Icons.receipt_long,
                  title: 'Lihat Detail Pesanan',
                  subtitle: 'Proses pesanan yang masuk dari pelanggan',
                  color: Colors.orange,
                  onTap: onNavigateToOrders,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      color: kCardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: kTextSecondary)),
        trailing: const Icon(Icons.chevron_right, color: kTextSecondary),
      ),
    );
  }
}
