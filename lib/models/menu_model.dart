import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String? ?? '🍽️',
      category: map['category'] as String? ?? 'Lainnya',
      isAvailable: map['isAvailable'] as bool? ?? true,
      stock: map['stock'] as int? ?? 50,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MenuModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'stock': stock,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Alias for toMap to match toFirestore usage in existing code.
  Map<String, dynamic> toFirestore() => toMap();

  MenuModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuModel(id: $id, name: $name, price: $price, category: $category, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
