import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import 'login_screen.dart';

/// Halaman Setup Awal - hanya digunakan SEKALI untuk membuat akun admin & seller.
/// Setelah akun dibuat, halaman ini tidak perlu digunakan lagi.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _isLoading = false;
  final List<String> _logs = [];

  final List<Map<String, String>> _accounts = [
    {
      'email': 'admin@gmail.com',
      'password': 'Password123',
      'name': 'Admin Kantin',
      'role': 'admin',
    },
    {
      'email': 'pedagang1@gmail.com',
      'password': 'Password098',
      'name': 'Pedagang Kantin 1',
      'role': 'seller',
    },
    {
      'email': 'pedagang2@gmail.com',
      'password': 'Password456',
      'name': 'Pedagang Kantin 2',
      'role': 'seller',
    },
  ];

  void _addLog(String message) {
    setState(() => _logs.add(message));
  }

  Future<void> _runSetup() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    _addLog('🚀 Memulai setup akun...');

    for (final account in _accounts) {
      _addLog('⏳ Membuat ${account['email']}...');
      try {
        // Gunakan secondary Firebase app agar tidak logout dari akun aktif
        FirebaseApp? secondaryApp;
        try {
          secondaryApp = Firebase.app('SetupApp');
        } catch (_) {
          secondaryApp = await Firebase.initializeApp(
            name: 'SetupApp',
            options: Firebase.app().options,
          );
        }

        final credential = await FirebaseAuth.instanceFor(app: secondaryApp)
            .createUserWithEmailAndPassword(
          email: account['email']!,
          password: account['password']!,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'name': account['name'],
          'email': account['email'],
          'role': account['role'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
        _addLog('✅ ${account['email']} berhasil dibuat (${account['role']})');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _addLog('⚠️ ${account['email']} sudah ada, dilewati.');
        } else {
          _addLog('❌ Error ${account['email']}: ${e.message}');
        }
      } catch (e) {
        _addLog('❌ Error: $e');
      }
    }

    _addLog('');
    _addLog('🎉 Setup selesai!');
    _addLog('');
    _addLog('📋 Akun yang tersedia:');
    _addLog('Admin: admin@kantin.com / Admin1234');
    _addLog('Pedagang 1: pedagang1@kantin.com / Pedagang1234');
    _addLog('Pedagang 2: pedagang2@kantin.com / Pedagang5678');

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        title: const Text(
          'Setup Awal Akun',
          style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Hanya Jalankan Sekali',
                    style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Halaman ini membuat akun Admin dan 2 Pedagang di Firebase. '
                    'Jika akun sudah ada, akan dilewati secara otomatis.',
                    style: TextStyle(fontSize: 13, color: kTextSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Akun yang akan dibuat:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _accountRow('👑 Admin', 'admin@gmail.com', 'Password123'),
            _accountRow('🏪 Pedagang 1', 'pedagang1@gmail.com', 'Password098'),
            _accountRow('🏪 Pedagang 2', 'pedagang2@gmail.com', 'Password456'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _runSetup,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch, color: Colors.white),
                label: Text(
                  _isLoading ? 'Membuat akun...' : 'Jalankan Setup',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (_logs.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, i) => Text(
                      _logs[i],
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _accountRow(String label, String email, String password) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(email, style: const TextStyle(fontSize: 12, color: kTextSecondary)),
              Text('pass: $password', style: const TextStyle(fontSize: 11, color: kTextSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
