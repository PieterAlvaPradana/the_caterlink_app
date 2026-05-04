import 'package:flutter/material.dart';
// Mengimpor package Flutter untuk UI.

import '../constants/app_colors.dart';
// Mengimpor konstanta warna aplikasi.

import 'home_screen.dart';
// Mengimpor halaman HomeScreen.

class LoginScreen extends StatefulWidget {
  // Widget stateful untuk login.

  const LoginScreen({super.key});
  // Constructor.

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  // Menghubungkan widget ke state.
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // State class + mixin untuk animasi.

  late TextEditingController _emailController;
  // Controller input email.

  late TextEditingController _passwordController;
  // Controller input password.

  late AnimationController _animationController;
  // Controller animasi.

  @override
  void initState() {
    // Dipanggil pertama kali.

    super.initState();

    _emailController = TextEditingController(text: 'a@a');
    // Nilai default email.

    _passwordController = TextEditingController(text: 'a@a');
    // Nilai default password.

    _animationController = AnimationController(
      // Inisialisasi animasi.
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();
    // Memulai animasi.
  }

  @override
  void dispose() {
    // Membersihkan resource.

    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Method utama build UI.

    return Scaffold(
      // Struktur dasar halaman.
      backgroundColor: kBackgroundColor,

      // Background aplikasi.
      body: SingleChildScrollView(
        // Agar bisa discroll.
        child: Padding(
          // Padding seluruh isi.
          padding: const EdgeInsets.all(24.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const SizedBox(height: 60),

              // Jarak atas.
              FadeTransition(
                // Animasi fade.
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(_animationController),

                child: Column(
                  children: [
                    Container(
                      // Box logo.
                      width: 80,
                      height: 80,

                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Center(
                        child: Text('🍽️', style: TextStyle(fontSize: 40)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      // Nama aplikasi.
                      'Canteen App',

                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: kTextPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      // Subtitle.
                      'Pesan makanan favorit Anda',

                      style: TextStyle(fontSize: 14, color: kTextSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              SlideTransition(
                // Input email animasi kiri.
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(_animationController),

                child: TextField(
                  controller: _emailController,

                  // Menghubungkan ke controller.
                  decoration: InputDecoration(
                    hintText: 'Email',

                    hintStyle: const TextStyle(color: kTextSecondary),

                    prefixIcon: const Icon(Icons.email, color: kPrimaryColor),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),

                      borderSide: const BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SlideTransition(
                // Input password animasi kanan.
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(_animationController),

                child: TextField(
                  controller: _passwordController,

                  // Controller password.
                  obscureText: true,

                  // Menyembunyikan password.
                  decoration: InputDecoration(
                    hintText: 'Password',

                    hintStyle: const TextStyle(color: kTextSecondary),

                    prefixIcon: const Icon(Icons.lock, color: kPrimaryColor),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),

                      borderSide: const BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              ScaleTransition(
                // Tombol animasi scale.
                scale: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.elasticOut,
                  ),
                ),

                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () => _navigateToHome(),

                    // Masuk ke Home.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      elevation: 8,
                    ),

                    child: const Text(
                      'Masuk',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
              // Spacer bawah.
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    // Fungsi pindah ke HomeScreen.

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        // Mengganti halaman login.
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),

        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              // Efek fade.
              opacity: animation,
              child: child,
            ),
      ),
    );
  }
}
