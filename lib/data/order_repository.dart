import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk user checkout dan membuat order baru, sekaligus mengurangi stok
  Future<String> createOrder(OrderModel order) async {
    final batch = _firestore.batch();
    
    // Create order doc
    final orderRef = _firestore.collection('orders').doc();
    batch.set(orderRef, order.toFirestore());

    // Reduce stock for each item
    for (var item in order.items) {
      final itemId = item['id'] as String;
      final quantity = item['quantity'] as int;
      
      final menuRef = _firestore
          .collection('sellers')
          .doc(order.sellerId)
          .collection('menus')
          .doc(itemId);
          
      batch.update(menuRef, {
        'stock': FieldValue.increment(-quantity)
      });
    }

    await batch.commit();
    return orderRef.id;
  }

  // Stream untuk seller melihat daftar pesanannya
  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Stream untuk user melihat history pesanannya
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Fungsi untuk seller mengupdate status pesanan (misal setelah scan QR)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }
  
  // Ambil detail satu order dari ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromFirestore(doc);
    }
    return null;
  }
}
