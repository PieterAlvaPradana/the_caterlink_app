import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seller_menu_item.dart';

/// Repository untuk operasi CRUD menu seller di Firestore.
///
/// Struktur Firestore:
/// ```
/// sellers/{sellerId}/menus/{menuId}
/// ```
///
/// Screen tidak boleh langsung akses Firestore.
/// Semua operasi melewati repository ini.
class SellerMenuRepository {
  final FirebaseFirestore _firestore;

  SellerMenuRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Referensi ke subcollection menus milik seller tertentu.
  CollectionReference<Map<String, dynamic>> _menusRef(String sellerId) {
    return _firestore.collection('sellers').doc(sellerId).collection('menus');
  }

  /// Stream realtime daftar menu seller, diurutkan berdasarkan waktu dibuat.
  Stream<List<SellerMenuItem>> getMenuStream(String sellerId) {
    return _menusRef(sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SellerMenuItem.fromFirestore(doc))
          .toList();
    });
  }

  /// Menambahkan menu baru ke Firestore.
  Future<void> addMenu(String sellerId, SellerMenuItem item) async {
    await _menusRef(sellerId).add(item.toFirestore());
  }

  /// Mengupdate menu yang sudah ada.
  Future<void> updateMenu(String sellerId, SellerMenuItem item) async {
    await _menusRef(sellerId).doc(item.id).update(
          item
              .copyWith(updatedAt: DateTime.now())
              .toFirestore(),
        );
  }

  /// Menghapus menu berdasarkan ID.
  Future<void> deleteMenu(String sellerId, String menuId) async {
    await _menusRef(sellerId).doc(menuId).delete();
  }

  /// Toggle ketersediaan menu (tersedia ↔ habis).
  Future<void> toggleAvailability(
    String sellerId,
    String menuId,
    bool isAvailable,
  ) async {
    await _menusRef(sellerId).doc(menuId).update({
      'isAvailable': isAvailable,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
