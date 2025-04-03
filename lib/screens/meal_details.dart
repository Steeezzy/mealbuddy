import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this import

class MealDetailScreen extends StatefulWidget {
  final String mealName;
  final String price;
  final String imageUrl;
  final String restaurantName;
  final String ingredients; // Add this parameter for ingredients
  final String extras; // Add this parameter for extras
  final int mealId; // Add this parameter

  const MealDetailScreen({
    super.key,
    required this.mealName,
    required this.price,
    required this.imageUrl,
    required this.restaurantName,
    required this.ingredients,
    this.extras = '',
    required this.mealId, // Make it required
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  static const Color primaryColor = Color.fromARGB(255, 139, 195, 74);
  static const double defaultPadding = 10.0;
  static const double borderRadius = 10.0;
  
  double _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;
  bool _hasUserReviewed = false;
  String _userReviewId = '';

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // Fetch reviews for this meal from the database
  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      // Fetch all reviews for this meal without joining with profiles
      final data = await supabase
          .from('reviews')
          .select('*')  // Changed from '*, profiles(name)'
          .eq('meal_id', widget.mealId)
          .order('created_at', ascending: false);
      
      print('Fetched reviews: $data'); // Add this for debugging
      
      // Check if the current user has already reviewed this meal
      if (user != null) {
        final userReview = await supabase
            .from('reviews')
            .select()
            .eq('meal_id', widget.mealId)
            .eq('user_id', user.id)
            .maybeSingle();
        
        if (userReview != null) {
          setState(() {
            _hasUserReviewed = true;
            _userReviewId = userReview['id'].toString();
            _userRating = userReview['rating'].toDouble();
            _reviewController.text = userReview['comment'];
          });
        }
      }
      
      setState(() {
        _reviews = List<Map<String, dynamic>>.from(data);
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() => _isLoadingReviews = false);
    }
  }

  // Submit or update a review
  Future<void> _submitReview() async {
    if (_userRating <= 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both a rating and a comment')),
      );
      return;
    }
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to leave a review')),
        );
        return;
      }
      
      final reviewData = {
        'meal_id': widget.mealId, // Use mealId instead of mealName
        'user_id': user.id,
        'rating': _userRating.toInt(),
        'comment': _reviewController.text,
      };
      
      if (_hasUserReviewed && _userReviewId.isNotEmpty) {
        // Update existing review
        await supabase
            .from('reviews')
            .update(reviewData)
            .eq('id', _userReviewId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your review has been updated')),
        );
      } else {
        // Insert new review
        await supabase.from('reviews').insert(reviewData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your review has been submitted')),
        );
      }
      
      // Refresh reviews
      _fetchReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
      print('Error submitting review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: defaultPadding),
          _buildRestaurantName(),
          Expanded(
            child: _buildMealDetails(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
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

  Widget _buildRestaurantName() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.restaurantName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMealDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildMealImage(),
              const SizedBox(height: 20),
              _buildMealInfo(),
              _buildIngredientsSection(),
              _buildNutritionalSection(),
              _buildReviewSection(),
              _buildReviewsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        widget.imageUrl,
        width: 300,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImagePlaceholder();
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const Icon(Icons.fastfood, color: Colors.white, size: 60),
    );
  }

  Widget _buildMealInfo() {
    return Column(
      children: [
        Text(
          widget.mealName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          '₹${widget.price}',
          style: const TextStyle(fontSize: 14, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    // Split the comma-separated ingredients into a list
    List<String> ingredientsList = widget.ingredients.split(',')
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();
    
    // Split the comma-separated extras into a list
    List<String> extrasList = widget.extras.split(',')
        .map((extra) => extra.trim())
        .where((extra) => extra.isNotEmpty)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Ingredients :',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display ingredients
              ...ingredientsList.map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(ingredient),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              // Display extras if available
              if (extrasList.isNotEmpty) ...[
                SizedBox(height: 10),
                Text(
                  "Extras:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                ...extrasList.map((extra) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(extra),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Remove or comment out the original _buildIngredientsSection method that uses _buildInfoSection
  // Widget _buildIngredientsSection() {
  //   return _buildInfoSection(
  //     title: 'Ingredients :',
  //     content: '• Rice\n• Vegetables\n• Spices\n• Oil\n• Salt',
  //   );
  // }

  Widget _buildNutritionalSection() {
    return _buildInfoSection(
      title: 'Nutritional Value :',
      content: '• Calories: 450 kcal\n• Protein: 12g\n• Carbs: 65g\n• Fat: 15g\n• Fiber: 8g',
    );
  }

  Widget _buildInfoSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(content),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 10),
        const Text(
          'Rate this meal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        _buildRatingStars(),
        _buildReviewInput(),
        ElevatedButton(
          onPressed: _submitReview,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: const Text('Submit Review'),
        ),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _userRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => setState(() => _userRating = index + 1),
        );
      }),
    );
  }

  Widget _buildReviewInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: defaultPadding,
      ),
      child: TextField(
        controller: _reviewController,
        decoration: InputDecoration(
          hintText: 'Write your review...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No reviews yet. Be the first to review!'),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Replace ListView.builder with Column to avoid nested scrolling issues
        Column(
          children: _reviews.map((review) => _buildReviewItem(review)).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    // Debug print to see the review data structure
    print('Review item: $review');
    
    // Get user_id from review
    final String userId = review['user_id'] ?? 'Unknown User';
    
    // We'll use FutureBuilder to fetch and display the user name
    return FutureBuilder<String>(
      future: _getUserName(userId),
      builder: (context, snapshot) {
        // Default to "User" if name is not available yet
        final String userName = snapshot.data ?? "User";
        
        final DateTime createdAt = DateTime.parse(review['created_at'] ?? DateTime.now().toString());
        final String formattedDate = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        
        final int rating = review['rating'] is int ? review['rating'] : 0;
        final String comment = review['comment'] ?? 'No comment provided';
        
        return Container(
          margin: const EdgeInsets.only(bottom: defaultPadding),
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(comment),
            ],
          ),
        );
      },
    );
  }
}

// Helper method to get user name from user_login table
  Future<String> _getUserName(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Query the user_login table with the correct column type
      final data = await supabase
          .from('user_login')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();
      
      print('User data: $data'); // Debug print to see available columns
      
      if (data != null) {
        // Prioritize full_name over other columns
        if (data['full_name'] != null && data['full_name'].toString().isNotEmpty) {
          return data['full_name'];
        } else if (data['name'] != null && data['name'].toString().isNotEmpty) {
          return data['name'];
        } else if (data['username'] != null && data['username'].toString().isNotEmpty) {
          return data['username'];
        } else if (data['email'] != null && data['email'].toString().isNotEmpty) {
          return data['email'];
        } else {
          // Return a shortened version of the user ID if no name is found
          return "User ${userId.substring(0, 4)}...";
        }
      } else {
        return "Anonymous User";
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return "Anonymous User";
    }
  }