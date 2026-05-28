import 'package:cloud_firestore/cloud_firestore.dart';

class Tenant {
  final String id;
  //  ID unik untuk setiap tenant (UID dari Firebase)

  final String name;
  //  Nama tenant (contoh: Warung Mak Siti)

  final String imageUrl;
  //  Gambar / icon tenant

  final double rating;
  final int reviews;
  final double distance;
  final String estimatedTime;

  Tenant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.estimatedTime,
  });

  factory Tenant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tenant(
      id: doc.id,
      name: data['name'] ?? 'Kantin',
      imageUrl: data['imageUrl'] ?? '🏪',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: (data['reviews'] ?? 0) as int,
      distance: (data['distance'] ?? 0.0).toDouble(),
      estimatedTime: data['estimatedTime'] ?? '-',
    );
  }
}
