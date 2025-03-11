import 'package:flutter/material.dart';
import '../../models/dish.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _currentLocation = "Kochi, Kerala";
  bool _isLoading = false;
  
  // Sample dishes based on location in Kerala
  final Map<String, List<Dish>> _locationBasedDishes = {
    "Kochi, Kerala": [
      Dish(
        id: '1',
        name: 'Kerala Fish Curry',
        description: 'Spicy fish curry made with coconut milk, kokum, and traditional Kerala spices.',
        price: 220,
        imageUrl: 'https://images.unsplash.com/photo-1626777553635-be342a888e25',
        dietaryInfo: ['Non-Vegetarian', 'Spicy', 'Kerala Special'],
      ),
      Dish(
        id: '2',
        name: 'Appam with Stew',
        description: 'Soft lacy rice pancakes served with vegetable or chicken stew cooked in coconut milk.',
        price: 180,
        imageUrl: 'https://images.unsplash.com/photo-1630383249896-613ed9a6f25c',
        dietaryInfo: ['Vegetarian Option', 'Kerala Breakfast'],
      ),
    ],
    "Trivandrum, Kerala": [
      Dish(
        id: '3',
        name: 'Puttu and Kadala Curry',
        description: 'Steamed rice cake served with black chickpea curry.',
        price: 120,
        imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84',
        dietaryInfo: ['Vegetarian', 'Traditional'],
      ),
      Dish(
        id: '4',
        name: 'Trivandrum Biriyani',
        description: 'A unique style of biriyani with Malabar spices and meat.',
        price: 250,
        imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0',
        dietaryInfo: ['Non-Vegetarian', 'Spicy'],
      ),
    ],
    "Fort Kochi, Heritage Zone": [
      Dish(
        id: '5',
        name: 'Prawn Moilee',
        description: 'Prawns cooked in a mild coconut and turmeric sauce with green chillies.',
        price: 280,
        imageUrl: 'https://images.unsplash.com/photo-1626777553635-be342a888e25',
        dietaryInfo: ['Seafood', 'Mild Spicy'],
      ),
      Dish(
        id: '6',
        name: 'Beef Fry',
        description: 'Spicy beef chunks fried with coconut pieces and Kerala spices.',
        price: 220,
        imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84',
        dietaryInfo: ['Non-Vegetarian', 'Spicy'],
      ),
    ],
    "Munnar, Tea Gardens": [
      Dish(
        id: '7',
        name: 'Kerala Parotta with Beef Curry',
        description: 'Layered flatbread served with slow-cooked beef curry.',
        price: 190,
        imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84',
        dietaryInfo: ['Non-Vegetarian', 'Popular'],
      ),
      Dish(
        id: '8',
        name: 'Cardamom Tea',
        description: 'Fresh tea from Munnar plantations infused with cardamom.',
        price: 60,
        imageUrl: 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f',
        dietaryInfo: ['Beverage', 'Munnar Special'],
      ),
    ],
    "Alleppey, Backwaters": [
      Dish(
        id: '9',
        name: 'Karimeen Pollichathu',
        description: 'Pearl spot fish marinated in spices, wrapped in banana leaf and grilled.',
        price: 320,
        imageUrl: 'https://images.unsplash.com/photo-1626777553635-be342a888e25',
        dietaryInfo: ['Seafood', 'Backwater Special'],
      ),
      Dish(
        id: '10',
        name: 'Alleppey Fish Curry',
        description: 'Tangy fish curry with raw mango and coconut.',
        price: 240,
        imageUrl: 'https://images.unsplash.com/photo-1626777553635-be342a888e25',
        dietaryInfo: ['Non-Vegetarian', 'Tangy'],
      ),
    ],
  };

  List<Dish> get _recommendedDishes => _locationBasedDishes[_currentLocation] ?? [];

  void _updateLocation(String newLocation) {
    setState(() {
      _isLoading = true;
      _currentLocation = newLocation;
    });
    
    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MealBuddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.pushNamed(context, '/chatbot');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF8BC34A)),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _currentLocation,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _updateLocation(newValue);
                      }
                    },
                    items: _locationBasedDishes.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Recommendations based on location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Recommended for you in $_currentLocation',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Dishes list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recommendedDishes.isEmpty
                    ? const Center(
                        child: Text('No recommendations available for this location'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recommendedDishes.length,
                        itemBuilder: (context, index) {
                          final dish = _recommendedDishes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/meal-details',
                                  arguments: dish,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    dish.imageUrl,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.restaurant, size: 60),
                                        ),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dish.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${dish.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8BC34A),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          dish.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          children: (dish.dietaryInfo ?? []).map((info) {
                                            return Chip(
                                              label: Text(
                                                info,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              backgroundColor: const Color(0xFFE8F5E9),
                                              padding: EdgeInsets.zero,
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}