import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String sellerId;
  final String sellerName;
  final List<dynamic> items; // List of map {name, quantity, price}
  final double totalPrice;
  final String status; // pending, processing, done, cancelled, paid
  final String paymentMethod;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userEmail = '',
    required this.sellerId,
    required this.sellerName,
    required this.items,
    required this.totalPrice,
    required this.status,
    this.paymentMethod = 'cash',
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      items: map['items'] ?? [],
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'cash',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OrderModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'items': items,
      'totalPrice': totalPrice,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'items': items,
      'totalPrice': totalPrice,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
