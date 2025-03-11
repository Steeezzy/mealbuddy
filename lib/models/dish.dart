class Dish {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String>? dietaryInfo;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.dietaryInfo,
  });
  
  // Add a factory constructor to create a Dish from a Map
  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      dietaryInfo: List<String>.from(map['dietaryInfo'] ?? []),
    );
  }
  
  // Add a method to convert a Dish to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'dietaryInfo': dietaryInfo,
    };
  }
}