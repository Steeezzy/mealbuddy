import 'package:flutter/material.dart';
import 'add_meals.dart';
import 'admin_menu.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<Map<String, dynamic>> _meals = []; // Use dynamic to handle different types
  static const Color primaryColor = Color.fromARGB(255, 139, 195, 74);
  static const Color backgroundColor = Color(0xFFF0F0F0);
  static const Color textColor = Color(0xFF333333);

  Future<void> _addMeal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMealScreen()),
    );
    if (result != null) {
      // Instead of adding to the list and then refreshing,
      // just refresh the meals list from the database
      _fetchMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MealBuddy",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Affordable, healthy meals near you",
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextButton.icon(
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Meals',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: _addMeal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminMenuScreen()),
            ),
          ),
        ),
      ],
    );
  }

  bool _isLoading = true;

    @override
    void initState() {
      super.initState();
      _fetchMeals();
    }
  
    Future<void> _fetchMeals() async {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final supabase = Supabase.instance.client;
        
        // Get the current user ID
        final currentUserId = supabase.auth.currentUser?.id;
        
        if (currentUserId == null) {
          throw Exception('User not authenticated');
        }
        
        // Fetch only meals created by the current user
        final response = await supabase
            .from('meal_details')
            .select()
            .eq('user_id', currentUserId); // Filter by user_id
        
        // Process the response to ensure image URLs are properly formatted
        final processedMeals = (response as List).map((meal) {
          final Map<String, dynamic> processedMeal = Map<String, dynamic>.from(meal);
          
          // If the image_url is a storage path, convert it to a full URL
          if (processedMeal['image_url'] != null && 
              processedMeal['image_url'].toString().isNotEmpty && 
              !processedMeal['image_url'].toString().startsWith('http')) {
            // Check if it's a storage path
            if (processedMeal['image_url'].toString().startsWith('storage/')) {
              // Convert to public URL
              processedMeal['image_url'] = supabase.storage
                  .from('meal_images') // Replace with your bucket name
                  .getPublicUrl(processedMeal['image_url'].toString().replaceFirst('storage/', ''));
            }
          }
          
          return processedMeal;
        }).toList();
        
        setState(() {
          _meals.clear();
          _meals.addAll(processedMeals.cast<Map<String, dynamic>>());
          _isLoading = false;
        });
        
        print('Fetched ${_meals.length} meals from database for user $currentUserId');
      } catch (e) {
        print('Error fetching meals: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }

    Widget _buildBody() {
      return Container(
        color: backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Meal Listings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _meals.length,
                    itemBuilder: (context, index) => MealCard(
                      name: _meals[index]['name'] ?? '',
                      price: _meals[index]['price'] ?? '',
                      ingredients: _meals[index]['ingredients'] ?? '',
                      // Removed extra parameter
                      imagePath: _meals[index]['image_url'],
                      index: index,
                      mealId: _meals[index]['id'], // Pass the meal ID
                      onEdit: _handleMealEdit,
                      onDelete: _handleMealDelete,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleMealEdit(int index, Map<String, dynamic> updatedMeal) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Ensure we have the ID from the original meal
      updatedMeal['id'] = _meals[index]['id'];
      
      // Update the meal in the database
      await supabase.from('meal_details').update(updatedMeal).eq('id', _meals[index]['id']);
      
      // Refresh the meals list to get the updated data
      _fetchMeals();
      
    } catch (e) {
      // Handle error
      print('Error updating meal: $e');
    }
  }

  void _handleMealDelete(int index) async {
    try {
      final supabase = Supabase.instance.client;
      final currentUserId = supabase.auth.currentUser?.id;
      
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Delete the meal, ensuring it belongs to the current user
      await supabase
          .from('meal_details')
          .delete()
          .eq('id', _meals[index]['id'])
          .eq('user_id', currentUserId);
          
      setState(() => _meals.removeAt(index));
    } catch (e) {
      // Handle error
      print('Error deleting meal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting meal: $e')),
      );
    }
  }
}

class MealCard extends StatelessWidget {
  final String name;
  final String price;
  final String ingredients;
  // Removed extra field
  final String? imagePath;
  final int index;
  final dynamic mealId; // Add mealId parameter
  final Function(int, Map<String, dynamic>) onEdit;
  final Function(int) onDelete;

  const MealCard({
    super.key,
    required this.name,
    required this.price,
    required this.ingredients,
    // Removed extra parameter
    this.imagePath,
    required this.index,
    required this.mealId, // Initialize mealId
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: const Color(0xFFF9F9F9),
      child: InkWell(
        onTap: () => _handleEdit(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(5),
                  image: imagePath != null && imagePath!.isNotEmpty
                      ? DecorationImage(
                          image: imagePath!.startsWith('http') || kIsWeb
                              ? NetworkImage(imagePath!)
                              : FileImage(File(imagePath!)) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Price: ₹$price',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF007BFF)),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => _showDeleteDialog(context),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF7ED957),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMealScreen(
          initialName: name,
          initialPrice: price,
          initialIngredients: ingredients,
          // Removed initialExtra
          initialImagePath: imagePath,
          mealId: mealId, // Use the passed mealId
          isEditing: true,
        ),
      ),
    );

    if (result != null) {
      onEdit(index, result as Map<String, dynamic>);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // First close the dialog
              Navigator.pop(context);
              // Then delete the meal
              onDelete(index);
            },
          ),
        ],
      ),
    );
  }
}