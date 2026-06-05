import 'package:cloud_firestore/cloud_firestore.dart';

class TenantModel {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final int reviews;
  final double distance;
  final String estimatedTime;

  TenantModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.estimatedTime,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map, String id) {
    return TenantModel(
      id: id,
      name: map['name'] as String? ?? 'Kantin',
      imageUrl: map['imageUrl'] as String? ?? '🏪',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: map['reviews'] as int? ?? 0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      estimatedTime: map['estimatedTime'] as String? ?? '-',
    );
  }

  factory TenantModel.fromFirestore(DocumentSnapshot doc) {
    return TenantModel.fromMap(
      doc.data() as Map<String, dynamic>? ?? {},
      doc.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviews': reviews,
      'distance': distance,
      'estimatedTime': estimatedTime,
    };
  }
}
