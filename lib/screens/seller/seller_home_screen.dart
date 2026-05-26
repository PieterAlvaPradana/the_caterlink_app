import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../data/seller_menu_repository.dart';
import '../../models/seller_menu_item.dart';
import '../login_screen.dart';
import 'widgets/add_menu_bottom_sheet.dart';

/// Halaman utama seller — menampilkan daftar menu realtime dari Firestore.
///
/// Fitur:
/// - AppBar dengan profil & logout
/// - StreamBuilder untuk realtime Firestore
/// - Responsive grid layout (1 kolom mobile, 2 kolom tablet)
/// - FAB untuk tambah menu
/// - Empty, loading, error states
/// - Toggle availability, edit, delete
class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen>
    with SingleTickerProviderStateMixin {
  final SellerMenuRepository _repository = SellerMenuRepository();
  late final AnimationController _fabAnimationController;

  // TODO: Ganti dengan FirebaseAuth.instance.currentUser!.uid
  // setelah Firebase Auth terintegrasi.
  static const String _sellerId = 'demo_seller_001';

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildMenuStats(),
          _buildMenuList(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: kCardColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Saya',
              style: TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Kelola menu toko Anda',
              style: TextStyle(
                color: kTextSecondary,
                fontWeight: FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 12),
                      Text('Profil'),
                    ],
                  ),
                  onTap: () {},
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: kDangerColor),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(color: kDangerColor),
                      ),
                    ],
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: setOpacity(kPrimaryColor, 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS HEADER — realtime count
  // ============================================================

  SliverToBoxAdapter _buildMenuStats() {
    return SliverToBoxAdapter(
      child: StreamBuilder<List<SellerMenuItem>>(
        stream: _repository.getMenuStream(_sellerId),
        builder: (context, snapshot) {
          final totalMenu = snapshot.data?.length ?? 0;
          final availableMenu =
              snapshot.data?.where((m) => m.isAvailable).length ?? 0;
          final unavailableMenu = totalMenu - availableMenu;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _buildStatChip(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Total',
                  value: '$totalMenu',
                  color: kPrimaryColor,
                ),
                const SizedBox(width: 10),
                _buildStatChip(
                  icon: Icons.check_circle_rounded,
                  label: 'Tersedia',
                  value: '$availableMenu',
                  color: kSuccessColor,
                ),
                const SizedBox(width: 10),
                _buildStatChip(
                  icon: Icons.cancel_rounded,
                  label: 'Habis',
                  value: '$unavailableMenu',
                  color: kDangerColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MENU LIST — StreamBuilder realtime
  // ============================================================

  Widget _buildMenuList() {
    return StreamBuilder<List<SellerMenuItem>>(
      stream: _repository.getMenuStream(_sellerId),
      builder: (context, snapshot) {
        // ERROR STATE
        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildErrorState(snapshot.error.toString()),
          );
        }

        // LOADING STATE
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildShimmerCard(),
                childCount: 4,
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        // EMPTY STATE
        if (items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          );
        }

        // DATA STATE — responsive layout
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: _buildResponsiveGrid(items),
        );
      },
    );
  }

  /// Grid responsif: 1 kolom di mobile, 2 kolom di tablet.
  Widget _buildResponsiveGrid(List<SellerMenuItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          // Tablet: 2 kolom grid
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMenuCard(items[index], index),
              childCount: items.length,
            ),
          );
        }

        // Mobile: 1 kolom list
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildMenuCard(items[index], index),
            childCount: items.length,
          ),
        );
      },
    );
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget _buildMenuCard(SellerMenuItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Emoji / Image area
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: item.isAvailable
                      ? setOpacity(kPrimaryColor, 0.1)
                      : setOpacity(kTextSecondary, 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.imageUrl,
                    style: TextStyle(
                      fontSize: 32,
                      color: item.isAvailable ? null : kTextSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Info area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama + kategori
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: item.isAvailable
                                  ? kTextPrimary
                                  : kTextSecondary,
                              decoration: item.isAvailable
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: setOpacity(kAccentColor, 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: kAccentColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Deskripsi
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Harga + actions
                    Row(
                      children: [
                        Text(
                          _formatRupiah(item.price),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: item.isAvailable
                                ? kPrimaryColor
                                : kTextSecondary,
                          ),
                        ),
                        const Spacer(),

                        // Toggle availability
                        SizedBox(
                          height: 28,
                          child: Switch.adaptive(
                            value: item.isAvailable,
                            onChanged: (value) =>
                                _toggleAvailability(item, value),
                            activeTrackColor: kSuccessColor,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Edit button
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          color: kPrimaryColor,
                          onTap: () => _editMenu(item),
                        ),

                        const SizedBox(width: 6),

                        // Delete button
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          color: kDangerColor,
                          onTap: () => _showDeleteDialog(item),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: setOpacity(color, 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: setOpacity(kPrimaryColor, 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍽️', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai tambahkan menu pertama Anda\ndengan menekan tombol + di bawah',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewMenu,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Tambah Menu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: setOpacity(kPrimaryColor, 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: setOpacity(kDangerColor, 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: kDangerColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: kTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: const BorderSide(color: kPrimaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHIMMER / LOADING STATE
  // ============================================================

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Shimmer image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kTextSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: kTextSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: kTextSecondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: kTextSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAB
  // ============================================================

  Widget _buildFAB() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
      child: FloatingActionButton.extended(
        onPressed: _addNewMenu,
        backgroundColor: kPrimaryColor,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _addNewMenu() {
    showAddMenuBottomSheet(
      context,
      sellerId: _sellerId,
      repository: _repository,
    );
  }

  void _editMenu(SellerMenuItem item) {
    showAddMenuBottomSheet(
      context,
      sellerId: _sellerId,
      repository: _repository,
      existingItem: item,
    );
  }

  Future<void> _toggleAvailability(SellerMenuItem item, bool value) async {
    try {
      await _repository.toggleAvailability(_sellerId, item.id, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal mengubah status: $e'),
            backgroundColor: kDangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(SellerMenuItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Menu',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: kTextPrimary, fontSize: 14),
              children: [
                const TextSpan(text: 'Apakah Anda yakin ingin menghapus '),
                TextSpan(
                  text: item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '?\n\nTindakan ini tidak bisa dibatalkan.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await _repository.deleteMenu(_sellerId, item.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('🗑️ ${item.name} berhasil dihapus'),
                        backgroundColor: kTextSecondary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Gagal menghapus: $e'),
                        backgroundColor: kDangerColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDangerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const LoginScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: kDangerColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatRupiah(double price) {
    final formatted = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return 'Rp $formatted';
  }
}
