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
  // await _seedFoodItems();

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

