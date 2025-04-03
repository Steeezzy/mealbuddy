import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_page.dart';
import 'chatbot_page.dart';
import 'restaurant_details.dart';
import 'meal_details.dart';
import 'meal_plans_screen.dart';

class MealBuddyHome extends StatefulWidget {
  const MealBuddyHome({Key? key}) : super(key: key);

  @override
  State<MealBuddyHome> createState() => _MealBuddyHomeState();
}

class _MealBuddyHomeState extends State<MealBuddyHome> {
  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;
  bool _isLoadingLocation = true;
  bool _isLoadingRestaurants = true; // Add this line
  
  final List<String> states = ['Kerala'];
  double _budget = 500;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  bool _isValidBudget = true;

  // Add this list to store restaurants
  List<Map<String, dynamic>> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _budgetController.text = _budget.toInt().toString(); // Initialize budget controller
    _fetchUserLocation().then((_) {
      _fetchRestaurants(); // Fetch restaurants after getting user location
    });
  }
  
  // Update this method to fetch restaurants based on user location
  Future<void> _fetchRestaurants() async {
    setState(() => _isLoadingRestaurants = true);
    
    try {
      final supabase = Supabase.instance.client;
      List<Map<String, dynamic>> restaurantsData = [];
      
      // First check if we have user location
      if (selectedState != null && selectedDistrict != null) {
        // Debug print to see what values are being used
        print('Fetching restaurants with: State=$selectedState, District=$selectedDistrict, City=$selectedCity');
        
        // Create a query builder for restaurants
        var query = supabase
            .from('restaurants')
            .select('*')
            .eq('state', selectedState as Object)
            .eq('district', selectedDistrict as Object);
        
        // Only filter by city if it's provided
        if (selectedCity != null && selectedCity!.isNotEmpty) {
          query = query.eq('city', selectedCity as Object);
        }
        
        // Execute the query with ordering
        restaurantsData = await query.order('resto_name');
      } else {
        // If no location is set, fetch all restaurants
        restaurantsData = await supabase
            .from('restaurants')
            .select('*')
            .order('resto_name');
      }
      
      // Process each restaurant to calculate ratings
      List<Map<String, dynamic>> processedData = [];
      
      for (var restaurant in restaurantsData) {
        // Get the restaurant ID (user_id in restaurants table)
        final restaurantId = restaurant['user_id'];
        
        // First, get all meals for this restaurant
        final mealsData = await supabase
            .from('meal_details')
            .select('id')
            .eq('user_id', restaurantId);
        
        double totalRating = 0.0;
        int totalReviews = 0;
        
        // For each meal, get its reviews
        for (var meal in mealsData) {
          final mealId = meal['id'];
          
          // Get reviews for this meal
          final reviewsData = await supabase
              .from('reviews')
              .select('rating')
              .eq('meal_id', mealId);
          
          // Add up all ratings
          for (var review in reviewsData) {
            if (review['rating'] != null) {
              totalRating += review['rating'];
              totalReviews++;
            }
          }
        }
        
        // Calculate average rating
        double avgRating = 0.0;
        if (totalReviews > 0) {
          avgRating = totalRating / totalReviews;
        }
        
        // Create a copy of the restaurant data with the calculated rating
        Map<String, dynamic> restaurantWithRating = Map.from(restaurant);
        restaurantWithRating['avg_rating'] = avgRating;
        restaurantWithRating['total_reviews'] = totalReviews;
        
        processedData.add(restaurantWithRating);
      }
      
      setState(() {
        _restaurants = processedData;
        _isLoadingRestaurants = false;
      });
    } catch (e) {
      print('Error fetching restaurants: $e');
      setState(() => _isLoadingRestaurants = false);
    }
  }

  Future<void> _fetchUserLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        final locationData = await supabase
            .from('user_location')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (locationData != null) {
          setState(() {
            selectedState = locationData['state'];
            selectedDistrict = locationData['district'];
            selectedCity = locationData['city'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _saveUserLocation(String state, String district, String city) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }
      
      // Check if location exists for this user
      final existingLocation = await supabase
          .from('user_location')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      
      final locationData = {
        'user_id': user.id,
        'state': state,
        'district': district,
        'city': city, // This can be empty string now
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (existingLocation != null) {
        // Update existing location
        await supabase
            .from('user_location')
            .update(locationData)
            .eq('user_id', user.id);
      } else {
        // Insert new location
        locationData['created_at'] = DateTime.now().toIso8601String();
        await supabase.from('user_location').insert(locationData);
      }
      
      // Refresh the restaurant list after updating location
      _fetchRestaurants();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving location: $e')),
      );
      print('Error saving location: $e');
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    cityController.dispose();
    super.dispose();
  }

  // Update the _showLocationDialog method
  void _showLocationDialog() {
    // Create local state variables for the dialog
    String? tempState = selectedState;
    String? tempDistrict = selectedDistrict;
    String? tempCity = selectedCity;
    
    // Initialize the cityController with current value
    cityController.text = tempCity ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(  // Wrap with StatefulBuilder
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Set Location'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: tempState,
                      decoration: InputDecoration(
                        labelText: 'State',
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      items: states.map((String state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          tempState = newValue;
                          tempDistrict = null;
                          tempCity = null;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: tempDistrict,
                      decoration: InputDecoration(
                        labelText: 'District',
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      items: tempState != null 
                        ? getDistricts(tempState!).map((String district) {
                            return DropdownMenuItem(
                              value: district,
                              child: Text(district),
                            );
                          }).toList()
                        : [],
                      onChanged: tempState != null 
                        ? (String? newValue) {
                            setState(() {
                              tempDistrict = newValue;
                              tempCity = null;
                            });
                          }
                        : null,
                      hint: Text('Select state first'),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City/Town',
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                        hintText: 'Enter your city/town',
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          tempCity = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8BC34A),
                  ),
                  child: Text('Save'),
                  onPressed: () {
                    if (tempState != null && tempDistrict != null) {
                      // Update the main state variables
                      this.setState(() {
                        selectedState = tempState;
                        selectedDistrict = tempDistrict;
                        selectedCity = cityController.text.isEmpty ? null : cityController.text;
                      });
                      
                      // Save location to Supabase
                      _saveUserLocation(
                        tempState!, 
                        tempDistrict!, 
                        cityController.text.isEmpty ? "" : cityController.text
                      );
                      
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select state and district'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Add these helper methods
  List<String> getDistricts(String state) {
    if (state == 'Kerala') {
      return [
        'Thiruvananthapuram',
        'Kollam',
        'Pathanamthitta',
        'Alappuzha',
        'Kottayam',
        'Idukki',
        'Ernakulam',
        'Thrissur',
        'Palakkad',
        'Malappuram',
        'Kozhikode',
        'Wayanad',
        'Kannur',
        'Kasaragod'
      ];
    }
    return [];
  }

  // Remove this unused method
  // List<String> getCities(String state, String district) { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 139, 195, 74),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("MealBuddy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Affordable, healthy meals near you", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on, color: Colors.white),
            onPressed: _showLocationDialog,
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: const Color.fromARGB(255, 139, 195, 74)),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search meals, restaurants, or cuisines",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Budget Slider
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("Budget: ₹${_budget.toInt()}", 
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter Budget',
                              hintText: 'Min: ₹100',
                              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                              errorText: _isValidBudget ? null : 'Invalid input',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _isValidBudget = false;
                                });
                                return;
                              }
                              if (RegExp(r'^[1-9]\d*$').hasMatch(value)) {
                                double newBudget = double.parse(value);
                                if (newBudget >= 100 && newBudget <= 5000) {
                                  setState(() {
                                    _budget = newBudget;
                                    _isValidBudget = true;
                                  });
                                } else {
                                  setState(() {
                                    _isValidBudget = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  _isValidBudget = false;
                                });
                              }
                            },  // Remove the extra else block
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _budget,
                      min: 100,  // Changed back to 100
                      max: 5000,
                      divisions: 49,
                      onChanged: (value) {
                        setState(() {
                          _budget = (value / 100).round() * 100;
                          _budgetController.text = _budget.toInt().toString();
                        });
                      },
                      activeColor: const Color.fromARGB(255, 139, 195, 74),
                      inactiveColor: Colors.grey[300],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // AI Recommendations
              Align(
                alignment: Alignment.centerLeft,
                child: Text("AI RECOMMENDATIONS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              // In the main build method, update the AI Recommendations container height
              Container(
                height: 250,  // Increased from 220 to accommodate all content
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    MealCard(name: "Vegetable Stir Fry", restaurant: "Thai Garden", distance: "0.5 mi", price: "699"),
                    MealCard(name: "Grilled Chicken Bowl", restaurant: "Health Hut", distance: "0.8 mi", price: "850"),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Nearby Restaurants
              Align(
                alignment: Alignment.centerLeft,
                child: Text("NEARBY RESTAURANTS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              // In the ListView.builder section, update to include the image URL
              Container(
                height: 400,
                child: _isLoadingRestaurants
                  ? Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 139, 195, 74)))
                  : _restaurants.isEmpty
                    ? Center(child: Text("No restaurants found near you"))
                    : ListView.builder(
                        itemCount: _restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = _restaurants[index];
                          // Format the rating to show only one decimal place
                          String formattedRating = restaurant['avg_rating'] != null && restaurant['avg_rating'] > 0
                              ? restaurant['avg_rating'].toStringAsFixed(1)
                              : "No ratings";
                          
                          return RestaurantCard(
                            name: restaurant['resto_name'] ?? 'Unknown Restaurant',
                            rating: formattedRating,
                            state: restaurant['state'] ?? '',
                            district: restaurant['district'] ?? '',
                            city: restaurant['city'] ?? '',
                            imageUrl: restaurant['image_url'] ?? '',
                            restaurantId: restaurant['user_id'], // Make sure to use user_id
                            totalReviews: restaurant['total_reviews'] ?? 0,
                          );
                        },
                      ),
              ),
              SizedBox(height: 16),  // Add bottom padding
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,  // Set to 0 to always highlight home in dashboard
        selectedItemColor: const Color.fromARGB(255, 139, 195, 74),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
// No need to set index since we're navigating away
          });
          if (index == 1) {  // Chat tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatbotPage(budget: _budget),
              ),
            );
          } else if (index == 2) {  // Plans tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealPlansScreen(),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Plans",
          ),
        ],
      ),
    );
  }
}

// Update the MealCard class to include mealId parameter when navigating to MealDetailScreen
class MealCard extends StatelessWidget {
  final String name, restaurant, distance, price;

  const MealCard({
    Key? key,
    required this.name,
    required this.restaurant,
    required this.distance,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(
              mealName: name,
              price: price,
              imageUrl: name == "Vegetable Stir Fry"
                  ? 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800'
                  : 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800',
              restaurantName: restaurant,
              ingredients: name == "Vegetable Stir Fry"
                  ? "Broccoli, Carrots, Bell Peppers, Snap Peas, Garlic, Ginger, Soy Sauce, Sesame Oil"
                  : "Grilled Chicken, Brown Rice, Avocado, Black Beans, Corn, Tomatoes, Lime, Cilantro",
              extras: name == "Vegetable Stir Fry"
                  ? "Tofu, Extra Sauce, Brown Rice"
                  : "Extra Avocado, Sour Cream, Tortilla Chips",
              mealId: name == "Vegetable Stir Fry" ? 1 : 2, // Add mealId parameter with dummy values
            ),
          ),
        );
      },
      child: Container(
      width: 200,
      margin: EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Added to better distribute space
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  name == "Vegetable Stir Fry"
                      ? 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800'
                      : 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800',
                  height: 130,  // Increased from 120
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              Text(
                name, 
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              SizedBox(height: 4),
              Text(
                "$restaurant • $distance", 
                style: TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "₹$price", 
            style: TextStyle(
              fontSize: 16,  // Increased from 14
              fontWeight: FontWeight.bold, 
              color: Colors.blue
            ),
          ),
        ],
      ),
    ));
  }
}

// Update the RestaurantCard class
class RestaurantCard extends StatelessWidget {
  final String name, rating, state, district, city, imageUrl;
  final dynamic restaurantId;
  final int totalReviews;

  const RestaurantCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.state,
    required this.district,
    required this.city,
    required this.imageUrl,
    required this.restaurantId,
    this.totalReviews = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsScreen(
              restaurantName: name,
              rating: rating,
              restaurantId: restaurantId, // Pass restaurant ID
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CircleAvatar(backgroundColor: Colors.grey[300], radius: 40);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback image in case of error
                      return Image.network(
                        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.network(
                    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    rating == "0.0" ? "No ratings yet" : "⭐ $rating (${totalReviews} ${totalReviews == 1 ? 'review' : 'reviews'})",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "$state, $district, $city",  // Fixed: replaced 'location' with state, district, city
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500
                    ),
                    overflow: TextOverflow.ellipsis,  // Added to handle long text
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color.fromARGB(255, 139, 195, 74),
              size: 24,  // Increased icon size
            ),
          ],
        ),
      ),
    );  // Close GestureDetector
  }  // Close build method
}  // Close RestaurantCard class