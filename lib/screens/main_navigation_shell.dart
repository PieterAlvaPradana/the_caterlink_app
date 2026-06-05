import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../models/tenant_model.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';

// Import Screens
import 'user/home_screen.dart';
import 'user/order_history_screen.dart';
import 'user/search_screen.dart';
import 'common/profile_screen.dart';

import 'admin/admin_home_screen.dart';
import 'admin/manage_tenant_screen.dart';
import 'admin/all_orders_screen.dart';

import 'seller/tenant_home_screen.dart';
import 'seller/seller_home_screen.dart';
import 'seller/seller_orders_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
          _isLoading = false;
        });
        return;
      }

      var userProfile = await _authService.getUserDetails(currentUser.uid);
      
      // Auto-heal missing Firestore records
      if (userProfile == null) {
        String defaultRole = 'user';
        final email = currentUser.email?.toLowerCase() ?? '';
        if (email.contains('admin')) {
          defaultRole = 'admin';
        } else if (email.contains('pedagang') || email.contains('seller') || email.contains('tenant')) {
          defaultRole = 'seller';
        }

        final defaultUser = UserModel(
          uid: currentUser.uid,
          name: currentUser.displayName ?? (email.isNotEmpty ? email.split('@')[0] : 'User'),
          email: currentUser.email ?? '',
          role: defaultRole,
          createdAt: DateTime.now(),
        );

        // Save back to Firestore 'users' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set(defaultUser.toMap());

        // If it's a seller, also write to 'tenants' collection
        if (defaultRole == 'seller') {
          final tenant = TenantModel(
            id: currentUser.uid,
            name: defaultUser.name,
            imageUrl: '🏪',
            rating: 0.0,
            reviews: 0,
            distance: 0.0,
            estimatedTime: '-',
          );
          await FirebaseFirestore.instance
              .collection('tenants')
              .doc(currentUser.uid)
              .set(tenant.toMap());
        }

        userProfile = defaultUser;
      }

      setState(() {
        _user = userProfile;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan memuat profil: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleLogout(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: kDangerColor),
          child: const Text('Keluar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await _authService.logout();
    if (!mounted) return; // avoid using a disposed context
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

  List<BottomNavigationBarItem> _getBottomNavItems() {
    if (_user == null) return [];

    final role = _user!.role.toLowerCase();

    if (role == 'admin') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_rounded),
          activeIcon: Icon(Icons.storefront_rounded),
          label: 'Tenant',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_rounded),
          activeIcon: Icon(Icons.analytics_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ];
    } else if (role == 'seller' || role == 'tenant') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store_rounded),
          activeIcon: Icon(Icons.store_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu_rounded),
          activeIcon: Icon(Icons.restaurant_menu_rounded),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ];
    } else {
      // Default: User
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          activeIcon: Icon(Icons.history_rounded),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          activeIcon: Icon(Icons.search_rounded),
          label: 'Cari',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ];
    }
  }

  Widget _buildActivePage() {
    if (_user == null) return const SizedBox.shrink();

    final role = _user!.role.toLowerCase();

    if (role == 'admin') {
      switch (_currentIndex) {
        case 0:
          return const AdminHomeScreen();
        case 1:
          return const AdminManageTenantScreen();
        case 2:
          return const AdminAllOrdersScreen();
        case 3:
          return ProfileScreen(user: _user!);
        default:
          return const AdminHomeScreen();
      }
    } else if (role == 'seller' || role == 'tenant') {
      switch (_currentIndex) {
        case 0:
          return TenantHomeScreen(
            onNavigateToMenu: () => setState(() => _currentIndex = 1),
            onNavigateToOrders: () => setState(() => _currentIndex = 2),
          );
        case 1:
          return const SellerHomeScreen();
        case 2:
          return const SellerOrdersScreen();
        case 3:
          return ProfileScreen(user: _user!);
        default:
          return TenantHomeScreen(
            onNavigateToMenu: () => setState(() => _currentIndex = 1),
            onNavigateToOrders: () => setState(() => _currentIndex = 2),
          );
      }
    } else {
      // Default: User
      switch (_currentIndex) {
        case 0:
          return const HomeScreen();
        case 1:
          return const OrderHistoryScreen();
        case 2:
          return const SearchScreen();
        case 3:
          return ProfileScreen(user: _user!);
        default:
          return const HomeScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kPrimaryColor),
              SizedBox(height: 16),
              Text(
                'Memuat profil pengguna...',
                style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: kDangerColor, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadUserProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _handleLogout(context),
                  child: const Text('Kembali ke Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _buildActivePage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: setOpacity(Colors.black, 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: kCardColor,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kTextSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: _getBottomNavItems(),
        ),
      ),
    );
  }
}
