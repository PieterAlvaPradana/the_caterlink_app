import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../../models/order.dart';
import 'package:intl/intl.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Dashboard Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kCardColor,
          elevation: 0,
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add, color: kPrimaryColor),
              onPressed: () => _showAddSellerDialog(context),
              tooltip: 'Tambah Seller',
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: kDangerColor),
              onPressed: () async {
                await AuthService().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: kPrimaryColor,
            unselectedLabelColor: kTextSecondary,
            indicatorColor: kPrimaryColor,
            tabs: [
              Tab(text: 'Sellers', icon: Icon(Icons.storefront)),
              Tab(text: 'Users', icon: Icon(Icons.people)),
              Tab(text: 'Dashboard Penjualan', icon: Icon(Icons.analytics)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersList('seller'),
            _buildUsersList('user'),
            _buildSalesDashboard(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // USER MANAGEMENT
  // ==========================================

  Widget _buildUsersList(String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').where('role', isEqualTo: role).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan'));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Belum ada $role terdaftar'));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              color: kCardColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                  child: Icon(role == 'seller' ? Icons.storefront : Icons.person, color: kPrimaryColor),
                ),
                title: Text(data['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['email'] ?? 'No Email'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: kDangerColor),
                  onPressed: () => _deleteUser(doc.id, data['name']),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteUser(String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Yakin ingin menghapus $name? Data tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kDangerColor),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('users').doc(uid).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengguna dihapus.')));
      }
    }
  }

  Future<void> _showAddSellerDialog(BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Seller Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Kantin/Penjual')),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email Seller')),
                  TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                ],
              ),
              actions: [
                if (!isLoading) TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          try {
                            await AuthService().registerTenant(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Seller berhasil ditambahkan!')));
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal: $e')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                        child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                      ),
              ],
            );
          }
        );
      },
    );
  }

  // ==========================================
  // SALES DASHBOARD
  // ==========================================

  Widget _buildSalesDashboard() {
    return Column(
      children: [
        Container(
          color: kCardColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari berdasarkan Email User/Seller...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_startDate == null ? 'Pilih Tanggal Mulai' : DateFormat('dd MMM yyyy').format(_startDate!)),
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
                      icon: const Icon(Icons.date_range),
                      label: Text(_endDate == null ? 'Pilih Tanggal Akhir' : DateFormat('dd MMM yyyy').format(_endDate!)),
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
              if (_startDate != null || _endDate != null || _searchQuery.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() {
                    _startDate = null;
                    _endDate = null;
                    _searchQuery = '';
                  }),
                  child: const Text('Reset Filter'),
                ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan'));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Belum ada transaksi'));
              }

              var orders = snapshot.data!.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();

              // Apply Filters
              if (_startDate != null) {
                orders = orders.where((o) => o.createdAt.isAfter(_startDate!)).toList();
              }
              if (_endDate != null) {
                orders = orders.where((o) => o.createdAt.isBefore(_endDate!)).toList();
              }
              if (_searchQuery.isNotEmpty) {
                orders = orders.where((o) {
                  return o.userName.toLowerCase().contains(_searchQuery) || 
                         o.sellerName.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              final totalRevenue = orders.where((o) => o.status != 'cancelled').fold(0.0, (acc, o) => acc + o.totalPrice);
              final totalOrders = orders.length;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Total Pesanan', style: TextStyle(color: kTextSecondary)),
                            Text('$totalOrders', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Total Pendapatan', style: TextStyle(color: kTextSecondary)),
                            Text('Rp${totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
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
                          child: ExpansionTile(
                            title: Text('Order ID: ${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text('${order.sellerName} ➔ ${order.userName}', style: const TextStyle(fontSize: 12, color: kTextSecondary)),
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
                                    const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    ...order.items.map((item) => Text('- ${item['quantity']}x ${item['name']}')),
                                    const SizedBox(height: 8),
                                    Text('Total: Rp${order.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
                                    const SizedBox(height: 8),
                                    Text('Date: ${DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt)}', style: const TextStyle(fontSize: 10, color: kTextSecondary)),
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
    );
  }
}
