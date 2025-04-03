import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMealScreen extends StatefulWidget {
  final String? initialName;
  final String? initialPrice;
  final String? initialIngredients;
  // Removed initialExtra
  final String? initialImagePath;
  final dynamic mealId; // Add this to store the meal ID
  final bool isEditing;

  const AddMealScreen({
    Key? key,
    this.initialName,
    this.initialPrice,
    this.initialIngredients,
    // Removed initialExtra parameter
    this.initialImagePath,
    this.mealId,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  // Removed extraController

  static const Color primaryColor = Color(0xFF8BC34A);
  static const Color backgroundColor = Color(0xFFF0F0F0);
  static const Color borderColor = Color(0xFFE0E0E0);

  File? _selectedImage;
  String? _imageUrl; // Variable to store image URL for web
  String? _imagePath; // Add this variable to store the image path

  // Method to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          // Handle web image upload and get URL
          _imageUrl = pickedFile.path; // Placeholder for actual URL
          _imagePath = pickedFile.path;
        } else {
          _selectedImage = File(pickedFile.path);
          _imagePath = pickedFile.path;
        }
      });
    }
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: _getImageWidget(),
      ),
    );
  }
  
  Widget _getImageWidget() {
    // If we have a selected image (from picker)
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }
    
    // If we have an image URL (web or from database)
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Image.network(_imageUrl!, fit: BoxFit.cover);
    }
    
    // If we have an image path but no image loaded yet
    if (_imagePath != null && _imagePath!.isNotEmpty && !kIsWeb) {
      try {
        return Image.file(File(_imagePath!), fit: BoxFit.cover);
      } catch (e) {
        print('Error loading image from path: $e');
      }
    }
    
    // Default - no image
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Colors.grey, size: 24),
          Text('Upload Photos', style: TextStyle(fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildMainContainer(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.isEditing ? 'Edit Meal' : 'Add Meal',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Container(
      width: double.infinity,
      height: 550,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPhotoUpload(),
          const SizedBox(height: 20),
          _buildFormFields(),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        buildTextField('Name', nameController),
        const SizedBox(height: 15),
        buildTextField('Price', priceController),
        const SizedBox(height: 15),
        buildTextField('Ingredients', ingredientsController),
        // Removed extra field
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        minimumSize: const Size(320, 50),
      ),
      onPressed: _handleSubmit,
      child: Text(
        widget.isEditing ? 'Update Meal' : 'Add Meal',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  void _handleSubmit() async {
    final supabase = Supabase.instance.client;
    
    // Get the current user ID
    final currentUserId = supabase.auth.currentUser?.id;
    
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final mealData = {
      'name': nameController.text,
      'price': priceController.text,
      'ingredients': ingredientsController.text,
      // Removed extra field
      'image_url': _imagePath ?? (kIsWeb ? _imageUrl : _selectedImage?.path),
      'user_id': currentUserId, // Add the user_id to associate the meal with the current user
    };

    try {
      dynamic response;
      
      if (widget.isEditing) {
        // Update existing meal
        response = await supabase
            .from('meal_details')
            .update(mealData)
            .eq('id', widget.mealId)
            .eq('user_id', currentUserId) // Ensure the meal belongs to the current user
            .select();
            
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Insert new meal
        response = await supabase.from('meal_details').insert(mealData).select();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Return to admin dashboard with the meal data
      if (response != null && response.isNotEmpty) {
        Navigator.pop(context, response[0]);
      } else {
        // If response is empty, return the original data with ID
        if (widget.isEditing) {
          mealData['id'] = widget.mealId;
        }
        Navigator.pop(context, mealData);
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error ${widget.isEditing ? 'updating' : 'adding'} meal: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error ${widget.isEditing ? 'updating' : 'adding'} meal: $e');
    }
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName ?? '';
    priceController.text = widget.initialPrice ?? '';
    ingredientsController.text = widget.initialIngredients ?? '';
    // Removed extraController initialization
    _imagePath = widget.initialImagePath;
    
    // If we have an initial image path, set it for display
    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty) {
      if (widget.initialImagePath!.startsWith('http')) {
        _imageUrl = widget.initialImagePath;
      } else if (!kIsWeb) {
        _selectedImage = File(widget.initialImagePath!);
      }
    }
  }
  
  // When saving the meal, include the ID in the result
  void _saveMeal() {
    // Create a map with all the meal details
    final mealData = {
      'name': nameController.text,
      'price': priceController.text,
      'ingredients': ingredientsController.text,
      // Removed extra field
      'image_url': _imagePath,
    };
    
    // If editing, include the ID
    if (widget.isEditing && widget.mealId != null) {
      mealData['id'] = widget.mealId;
    }
    
    // Return the data to the previous screen
    Navigator.pop(context, mealData);
  }
}