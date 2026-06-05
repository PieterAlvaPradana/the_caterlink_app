import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';

class AdminManageTenantScreen extends StatefulWidget {
  const AdminManageTenantScreen({super.key});

  @override
  State<AdminManageTenantScreen> createState() => _AdminManageTenantScreenState();
}

class _AdminManageTenantScreenState extends State<AdminManageTenantScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await _firestore.collection('tenants').doc(uid).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tenant berhasil dihapus.')));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Tambah Seller Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Kantin/Penjual',
                      hintText: 'Masukkan nama kantin',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Seller',
                      hintText: 'seller@gmail.com',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimal 6 karakter',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Semua field wajib diisi')),
                            );
                            return;
                          }
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
                                const SnackBar(content: Text('Seller berhasil ditambahkan!')),
                              );
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                        child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
              ],
            );
          },
        );
      },
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
          'Kelola Tenant',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSellerDialog(context),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Tenant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').where('role', isEqualTo: 'seller').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return const Center(child: Text('Terjadi kesalahan memuat data.'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada tenant terdaftar'));
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
                elevation: 3,
                shadowColor: Colors.black.withValues(alpha: 0.04),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.storefront, color: kPrimaryColor),
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
      ),
    );
  }
}
