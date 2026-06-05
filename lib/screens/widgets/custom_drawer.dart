import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  final String role;
  final String name;
  final String email;
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.role,
    required this.name,
    required this.email,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onLogout,
  });

  String _getRoleDisplayName() {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'seller':
      case 'tenant':
        return 'TENANT';
      default:
        return 'MAHASISWA';
    }
  }

  List<Map<String, dynamic>> _getMenuItems() {
    final lowerRole = role.toLowerCase();
    if (lowerRole == 'admin') {
      return [
        {'title': 'Home', 'icon': Icons.dashboard_rounded, 'index': 0},
        {'title': 'Manage Tenant', 'icon': Icons.storefront_rounded, 'index': 1},
        {'title': 'View All Orders', 'icon': Icons.analytics_rounded, 'index': 2},
        {'title': 'Profile', 'icon': Icons.person_rounded, 'index': 3},
      ];
    } else if (lowerRole == 'seller' || lowerRole == 'tenant') {
      return [
        {'title': 'Home', 'icon': Icons.store_rounded, 'index': 0},
        {'title': 'Manage Menu', 'icon': Icons.restaurant_menu_rounded, 'index': 1},
        {'title': 'Order History', 'icon': Icons.receipt_long_rounded, 'index': 2},
        {'title': 'Profile', 'icon': Icons.person_rounded, 'index': 3},
      ];
    } else {
      // Default: Mahasiswa
      return [
        {'title': 'Home', 'icon': Icons.home_rounded, 'index': 0},
        {'title': 'Order History', 'icon': Icons.history_rounded, 'index': 1},
        {'title': 'Search', 'icon': Icons.search_rounded, 'index': 2},
        {'title': 'Profile', 'icon': Icons.person_rounded, 'index': 3},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();
    final roleName = _getRoleDisplayName();
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: kBackgroundColor,
      child: Column(
        children: [
          // Premium Custom Header
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryColor,
                  kPrimaryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                // User Avatar Circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // User Profile details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roleName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Dynamic Menu items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, i) {
                final item = menuItems[i];
                final isSelected = currentIndex == item['index'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? kPrimaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected ? kPrimaryColor : kTextSecondary,
                        size: 22,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: isSelected ? kPrimaryColor : kTextPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Close Drawer first
                        Navigator.pop(context);
                        onItemSelected(item['index'] as int);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Divider and Logout Footer
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: kDangerColor.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: kDangerColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: kDangerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
