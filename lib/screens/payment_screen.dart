// Mengimpor package utama Flutter untuk membangun UI
import 'package:flutter/material.dart';

// Mengimpor konstanta warna aplikasi
import '../constants/app_colors.dart';

// Mengimpor halaman QR Code
import 'qr_code_screen.dart';


// Membuat halaman PaymentScreen dengan StatefulWidget
class PaymentScreen extends StatefulWidget {
  
  // Menyimpan total pembayaran
  final double totalAmount;

  // Constructor untuk menerima totalAmount
  const PaymentScreen({super.key, required this.totalAmount});

  // Membuat state untuk widget ini
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}


// State class untuk PaymentScreen
class _PaymentScreenState extends State<PaymentScreen> {
  
  // Menyimpan metode pembayaran yang dipilih
  String selectedPaymentMethod = 'cash';

  // Daftar metode pembayaran
  final paymentMethods = [
    {'id': 'cash', 'name': 'Tunai', 'icon': '💵'},
    {'id': 'card', 'name': 'Kartu Debit/Kredit', 'icon': '💳'},
    {'id': 'transfer', 'name': 'Transfer Bank', 'icon': '🏦'},
    {'id': 'ewallet', 'name': 'E-Wallet', 'icon': '📱'},
  ];

  // Fungsi utama membangun UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // Warna background halaman
      backgroundColor: kBackgroundColor,

      // AppBar atas
      appBar: AppBar(
        backgroundColor: kCardColor,
        elevation: 0,

        // Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),

        // Judul halaman
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Isi halaman
      body: Column(
        children: [

          // Konten utama scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Kartu total pembayaran
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryColor, kAccentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: setOpacity(kPrimaryColor, 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        // Label total pembayaran
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Menampilkan total nominal
                        Text(
                          'Rp${widget.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Judul section metode pembayaran
                  const Text(
                    'Pilih Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Menampilkan semua metode pembayaran
                  ...paymentMethods.map(
                    (method) => _buildPaymentMethodCard(method),
                  ),
                ],
              ),
            ),
          ),

          // Tombol bawah bayar
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

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  // Jalankan proses pembayaran
                  onPressed: () => _processPayment(),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    elevation: 8,
                  ),

                  child: const Text(
                    'Bayar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Fungsi membangun kartu metode pembayaran
  Widget _buildPaymentMethodCard(Map<String, String> method) {
    
    // Mengecek apakah metode ini sedang dipilih
    bool isSelected = selectedPaymentMethod == method['id'];

    return GestureDetector(

      // Saat ditekan, ubah metode pembayaran
      onTap: () => setState(
        () => selectedPaymentMethod = method['id']!,
      ),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: isSelected
              ? setOpacity(kPrimaryColor, 0.1)
              : kCardColor,

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: isSelected
                ? kPrimaryColor
                : Colors.transparent,
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
            ),
          ],
        ),

        child: Row(
          children: [

            // Icon metode pembayaran
            Text(
              method['icon']!,
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(width: 12),

            // Nama metode pembayaran
            Expanded(
              child: Text(
                method['name']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? kPrimaryColor
                      : kTextPrimary,
                ),
              ),
            ),

            // Radio button custom
            Container(
              width: 20,
              height: 20,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                border: Border.all(
                  color: isSelected
                      ? kPrimaryColor
                      : kTextSecondary,
                  width: 2,
                ),

                color: isSelected
                    ? kPrimaryColor
                    : Colors.transparent,
              ),

              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }


  // Fungsi proses pembayaran
  void _processPayment() {
    
    // Navigasi ke halaman QR Code
    Navigator.of(context).push(
      PageRouteBuilder(

        pageBuilder: (context, animation, secondaryAnimation) =>
            const QRCodeScreen(),

        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
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
}