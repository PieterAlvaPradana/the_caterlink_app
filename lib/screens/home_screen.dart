import 'package:flutter/material.dart'; 
// Mengimpor package utama Flutter untuk membuat UI.

import '../constants/app_colors.dart'; 
// Mengimpor file warna global aplikasi.

import '../models/tenant.dart'; 
// Mengimpor model data Tenant.

import '../data/dummy_data.dart'; 
// Mengimpor data dummy tenant.

import 'menu_screen.dart'; 
// Mengimpor halaman menu.

import 'login_screen.dart'; 
// Mengimpor halaman login.

class HomeScreen extends StatefulWidget {
// Membuat widget stateful agar UI bisa berubah.

  const HomeScreen({super.key});
// Constructor HomeScreen.

  @override
  State<HomeScreen> createState() => _HomeScreenState();
// Menghubungkan widget dengan class state.
}

class _HomeScreenState extends State<HomeScreen> {
// State class untuk HomeScreen.

  @override
  Widget build(BuildContext context) {
// Method utama untuk merender UI.

    return Scaffold(
// Scaffold = struktur dasar halaman.

      backgroundColor: kBackgroundColor,
// Memberi warna background.

      body: CustomScrollView(
// Membuat body scrollable dengan sliver.

        slivers: [
// Daftar elemen sliver.

          SliverAppBar(
// AppBar fleksibel.

            expandedHeight: 100,
// Tinggi saat expand.

            floating: true,
// Muncul saat scroll ke atas.

            pinned: true,
// Tetap menempel di atas.

            elevation: 0,
// Menghilangkan shadow.

            backgroundColor: kCardColor,
// Warna background.

            flexibleSpace: FlexibleSpaceBar(
// Ruang fleksibel untuk title.

              title: const Text(
// Widget judul.

                'Pilih Kantin',
// Teks judul.

                style: TextStyle(
// Styling teks.

                  color: kTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              centerTitle: false,
// Posisi title ke kiri.
            ),

            actions: [
// Tombol kanan atas.

              Padding(
                padding: const EdgeInsets.only(right: 16),
// Memberi jarak kanan.

                child: Center(
// Menengahkan isi.

                  child: PopupMenuButton(
// Dropdown menu.

                    itemBuilder: (context) => [
// Daftar item menu.

                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.person, size: 20),
                            SizedBox(width: 12),
                            Text('Profil'),
                          ],
                        ),

                        onTap: () {},
// Aksi saat klik profil.
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
// Memanggil dialog logout.
                      ),
                    ],

                    child: Container(
// Tampilan tombol popup.

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
          ),

          SliverPadding(
// Memberi padding.

            padding: const EdgeInsets.all(16),

            sliver: SliverList(
// List dalam sliver.

              delegate: SliverChildListDelegate([
// Daftar child tetap.

                Container(
// Search container.

                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(12),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: TextField(
// Input pencarian.

                    decoration: InputDecoration(
                      hintText: 'Cari kantin...',
                      hintStyle: const TextStyle(color: kTextSecondary),

                      prefixIcon: const Icon(
                        Icons.search,
                        color: kTextSecondary,
                      ),

                      border: InputBorder.none,

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
// Builder dinamis list tenant.

                (context, index) =>
                    _buildTenantCard(context, dummyTenants[index]),

                childCount: dummyTenants.length,
// Jumlah tenant.
              ),
            ),
          ),

          SliverToBoxAdapter(
// Spacer bawah.

            child: const SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantCard(BuildContext context, Tenant tenant) {
// Widget card tenant.

    return GestureDetector(
// Membuat card bisa diklik.

      onTap: () => _navigateToMenu(context, tenant),
// Navigasi ke menu.

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
// Area gambar tenant.

              width: double.infinity,
              height: 180,

              decoration: BoxDecoration(
                color: setOpacity(kPrimaryColor, 0.1),

                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),

              child: Center(
                child: Text(
                  tenant.imageUrl,
// Emoji/gambar tenant.

                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    tenant.name,
// Nama tenant.

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
// Rating row.

                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${tenant.rating} (${tenant.reviews} ulasan)',
// Nilai rating.

                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
// Row estimasi + tombol.

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        tenant.estimatedTime,
// Estimasi waktu.

                        style: const TextStyle(
                          fontSize: 13,
                          color: kTextSecondary,
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Material(
                          color: Colors.transparent,

                          child: InkWell(
// Tombol pilih.

                            onTap: () =>
                                _navigateToMenu(context, tenant),

                            borderRadius: BorderRadius.circular(8),

                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),

                              child: Text(
                                'Pilih',

                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMenu(BuildContext context, Tenant tenant) {
// Fungsi pindah ke halaman menu.

    Navigator.of(context).push(
      PageRouteBuilder(
// Custom animasi page.

        pageBuilder: (context, animation, secondaryAnimation) =>
            MenuScreen(tenant: tenant),

        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                SlideTransition(
// Animasi geser.

                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),

                  child: child,
                ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
// Dialog logout.

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),

          content: const Text(
            'Apakah Anda yakin ingin logout?',
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
// Tutup dialog.

              child: const Text('Batal'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.of(context).pushAndRemoveUntil(
// Logout dan reset stack.

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
}