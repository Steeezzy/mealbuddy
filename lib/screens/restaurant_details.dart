import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'meal_details.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantName;
  final String rating;
  final dynamic restaurantId;

  static const Color primaryColor = Color.fromARGB(255, 139, 195, 74);
  static const double defaultPadding = 16.0;
  static const double borderRadius = 10.0;

  const RestaurantDetailsScreen({
    super.key,
    required this.restaurantName,
    required this.rating,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _meals = [];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  // In the _fetchMeals method of RestaurantDetailsScreen
  Future<void> _fetchMeals() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      
      final data = await supabase
          .from('meal_details')
          .select('*')
          .eq('user_id', widget.restaurantId)
          .order('name');
      
      setState(() {
        _meals = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching meals: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildRestaurantHeader(),
          Expanded(child: _buildMealsList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: RestaurantDetailsScreen.primaryColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "MealBuddy",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Affordable, healthy meals near you",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RestaurantDetailsScreen.defaultPadding),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.restaurantName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                widget.rating,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: RestaurantDetailsScreen.primaryColor,
        ),
      );
    }

    if (_meals.isEmpty) {
      return const Center(
        child: Text(
          "No meals available for this restaurant",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(RestaurantDetailsScreen.defaultPadding),
      itemCount: _meals.length,
      itemBuilder: (context, index) {
        final meal = _meals[index];
        return _buildMealCard(
          name: meal['name'] ?? 'Unknown Meal',
          price: meal['price']?.toString() ?? '0',
          imageUrl: meal['image_url'] ?? '',
        );
      },
    );
  }

  Widget _buildMealCard({
    required String name,
    required String price,
    required String imageUrl,
  }) {
    // Find the meal data from the _meals list to get ingredients and extras
    final mealData = _meals.firstWhere(
      (meal) => meal['name'] == name,
      orElse: () => {'ingredients': '', 'extras': '', 'id': 0}
    );
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              mealName: name,
              price: price,
              imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150',
              restaurantName: widget.restaurantName,
              ingredients: mealData['ingredients'] ?? '',
              extras: mealData['extras'] ?? '',
              mealId: mealData['id'] ?? 0, // Add the mealId parameter
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(RestaurantDetailsScreen.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(RestaurantDetailsScreen.borderRadius),
                bottomLeft: Radius.circular(RestaurantDetailsScreen.borderRadius),
              ),
              child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.network(
                    'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹$price",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_forward_ios,
                color: RestaurantDetailsScreen.primaryColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}