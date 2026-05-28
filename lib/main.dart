import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'screens/auth/role_checker.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  // Auto-seed data for the user
  await _seedFoodItems();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const CanteenApp(),
    ),
  );
}

class CanteenApp extends StatelessWidget {
  const CanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        useMaterial3: true,
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const RoleChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<void> _seedFoodItems() async {
  try {
    final sellers = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'seller')
        .get();

    for (var doc in sellers.docs) {
      final menuRef = FirebaseFirestore.instance
          .collection('sellers')
          .doc(doc.id)
          .collection('menus');

      final existing = await menuRef.limit(1).get();
      if (existing.docs.isEmpty) {
        // Create sample foods with stock 50
        await menuRef.add({
          'name': 'Nasi Goreng Spesial',
          'description': 'Nasi goreng dengan ayam dan sayuran.',
          'price': 25000.0,
          'imageUrl': '🍚',
          'category': 'Nasi',
          'isAvailable': true,
          'stock': 50,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await menuRef.add({
          'name': 'Ayam Bakar',
          'description': 'Ayam bakar madu manis gurih.',
          'price': 30000.0,
          'imageUrl': '🍗',
          'category': 'Meat',
          'isAvailable': true,
          'stock': 50,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await menuRef.add({
          'name': 'Es Teh Manis',
          'description': 'Es teh manis segar.',
          'price': 5000.0,
          'imageUrl': '🧋',
          'category': 'Drinks',
          'isAvailable': true,
          'stock': 50,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  } catch (_) {}
}
