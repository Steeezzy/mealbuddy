import 'dish.dart';

class AdminDish implements Dish {
  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double price;
  @override
  final String imageUrl;
  @override
  final List<String>? dietaryInfo; // Added missing property from Dish
  final String district;
  final String town;
  final bool isAvailable;
  final DateTime createdAt;

  AdminDish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.dietaryInfo, // Added to constructor
    required this.district,
    required this.town,
    this.isAvailable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert `AdminDish` to a Map (useful for Firebase Firestore or JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'dietaryInfo': dietaryInfo, // Added to map
      'district': district,
      'town': town,
      'isAvailable': isAvailable,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Factory constructor to create an `AdminDish` from a Map (deserialization)
  factory AdminDish.fromMap(Map<String, dynamic> map) {
    return AdminDish(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      dietaryInfo: map['dietaryInfo'] != null 
          ? List<String>.from(map['dietaryInfo']) 
          : null, // Added to fromMap
      district: map['district'] ?? '',
      town: map['town'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: _parseCreatedAt(map['createdAt']),
    );
  }

  /// Helper function to handle various `createdAt` formats
  static DateTime _parseCreatedAt(dynamic timestamp) {
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is Map && timestamp.containsKey('_seconds')) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
    }
    return DateTime.now();
  }
}