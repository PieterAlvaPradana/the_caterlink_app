class Tenant {
  final int id;
  final String name;
  final String imageUrl;
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
}
