import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../models/tenant_model.dart';
import 'menu_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToMenu(BuildContext context, TenantModel tenant) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MenuScreen(tenant: tenant),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
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
          'Cari Kantin',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Input Area
          Container(
            padding: const EdgeInsets.all(16),
            color: kCardColor,
            child: Container(
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama kantin / tenant...',
                  hintStyle: const TextStyle(color: kTextSecondary),
                  prefixIcon: const Icon(Icons.search, color: kTextSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: kTextSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          // Search Results
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tenants').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan memuat data.'));
                }

                final docs = snapshot.data?.docs ?? [];
                var tenants = docs.map((doc) => TenantModel.fromFirestore(doc)).toList();

                // Apply local search filtering
                if (_searchQuery.isNotEmpty) {
                  tenants = tenants.where((tenant) {
                    return tenant.name.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (tenants.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🏪', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'Belum ada kantin terdaftar' : 'Kantin tidak ditemukan',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Coba cari dengan kata kunci lain.',
                          style: TextStyle(color: kTextSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = tenants[index];
                    return Card(
                      color: kCardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      shadowColor: Colors.black.withValues(alpha: 0.04),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                          child: Text(
                            tenant.imageUrl,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        title: Text(
                          tenant.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: kTextPrimary),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${tenant.rating} (${tenant.reviews} ulasan)',
                                  style: const TextStyle(fontSize: 12, color: kTextSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Estimasi: ${tenant.estimatedTime}',
                              style: const TextStyle(fontSize: 12, color: kTextSecondary),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _navigateToMenu(context, tenant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Buka', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
