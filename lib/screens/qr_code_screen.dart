// Mengimpor package utama Flutter untuk UI
import 'package:flutter/material.dart';

// Mengimpor konstanta warna aplikasi
import '../constants/app_colors.dart';

// Mengimpor halaman home
import 'home_screen.dart';


// Membuat halaman QRCodeScreen dengan StatefulWidget
class QRCodeScreen extends StatefulWidget {
  
  // Constructor default
  const QRCodeScreen({super.key});

  // Membuat state widget
  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}


// State class untuk QRCodeScreen
// Menggunakan SingleTickerProviderStateMixin agar bisa menjalankan animasi
class _QRCodeScreenState extends State<QRCodeScreen>
    with SingleTickerProviderStateMixin {
  
  // Controller animasi
  late AnimationController _animationController;


  // Fungsi pertama kali dijalankan saat halaman dibuka
  @override
  void initState() {
    super.initState();

    // Membuat animasi berdurasi 2 detik
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )

    // Mengulang animasi terus-menerus
    ..repeat();
  }


  // Membersihkan controller saat widget ditutup
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  // Fungsi utama membangun tampilan UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Warna background halaman
      backgroundColor: kBackgroundColor,

      // Isi halaman
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Area utama
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Jarak atas
                  const SizedBox(height: 40),

                  // Icon centang sukses
                  const Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 60,
                      color: kSuccessColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Judul pembayaran sukses
                  const Text(
                    'Pembayaran Berhasil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Animasi zoom QR Code
                  ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.8,
                      end: 1,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.elasticInOut,
                      ),
                    ),

                    child: Container(
                      width: 240,
                      height: 240,

                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(16),

                        boxShadow: [
                          BoxShadow(
                            color: setOpacity(kPrimaryColor, 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      padding: const EdgeInsets.all(20),

                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Center(

                          // Menampilkan gambar QR dari asset
                          child: Image.asset(
                            'assets/qr_code_placeholder.png',
                            fit: BoxFit.cover,

                            // Jika gambar gagal dimuat
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [

                                  // QR placeholder custom
                                  Container(
                                    width: 160,
                                    height: 160,

                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                    ),

                                    // Pola kotak hitam putih
                                    child: GridView.count(
                                      crossAxisCount: 4,

                                      children: List.generate(
                                        16,

                                        (index) => Container(
                                          margin:
                                              const EdgeInsets.all(2),

                                          color: index % 2 == 0
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Instruksi penggunaan QR
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),

                    child: Text(
                      'Tunjukkan QR ini saat pengambilan pesanan',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 16,
                        color: kTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nomor pesanan
                  Text(
                    'Nomor Pesanan: #12345678',
                    style: TextStyle(
                      fontSize: 14,
                      color: kTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Area tombol bawah
          Container(
            decoration: BoxDecoration(
              color: kCardColor,

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),

            padding: const EdgeInsets.all(20),

            child: SafeArea(
              top: false,

              child: Column(
                children: [

                  // Tombol kembali ke home
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () => _backToHome(),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        elevation: 8,
                      ),

                      child: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol share QR
                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton(
                      onPressed: () {},

                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: kPrimaryColor,
                          width: 2,
                        ),

                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: const Text(
                        'Bagikan QR Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Fungsi kembali ke halaman home
  void _backToHome() {
    Navigator.of(context).pushAndRemoveUntil(

      // Transisi fade
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) =>
            const HomeScreen(),

        transitionsBuilder:
            (
              context,
              animation,
              secondaryAnimation,
              child,
            ) =>
                FadeTransition(
                  opacity: animation,
                  child: child,
                ),
      ),

      // Menghapus semua route sebelumnya
      (route) => false,
    );
  }
}