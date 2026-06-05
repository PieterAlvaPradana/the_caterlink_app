import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../models/tenant_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: userCredential.user!.uid,
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap());

    // If registering a seller directly from public sign up
    if (role == 'seller') {
      final tenant = TenantModel(
        id: user.uid,
        name: name,
        imageUrl: '🏪',
        rating: 0.0,
        reviews: 0,
        distance: 0.0,
        estimatedTime: '-',
      );
      await _firestore.collection('tenants').doc(user.uid).set(tenant.toMap());
    }
  }

  /// Registers a new Tenant. Designed to be called by Admin.
  /// Uses a secondary Firebase app instance to avoid logging out the currently logged-in Admin.
  Future<void> registerTenant({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app('TenantRegisterApp');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'TenantRegisterApp',
        options: Firebase.app().options,
      );
    }

    try {
      final userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Save user role data in 'users' collection
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: 'seller',
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      // Save tenant data in 'tenants' collection
      final tenantModel = TenantModel(
        id: uid,
        name: name,
        imageUrl: '🏪',
        rating: 0.0,
        reviews: 0,
        distance: 0.0,
        estimatedTime: '-',
      );
      await _firestore.collection('tenants').doc(uid).set(tenantModel.toMap());
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<String> getUserRole(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      return data['role'] as String? ?? 'user';
    }
    return 'user';
  }

  Future<UserModel?> getUserDetails(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
