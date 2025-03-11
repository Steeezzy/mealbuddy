import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  XFile? selectedImage;
  
  // Dietary preferences
  final Map<String, bool> dietaryPreferences = {
    'Vegetarian': false,
    'Vegan': false,
    'Gluten-Free': false,
    'Dairy-Free': false,
    'Nut-Free': false,
    'Low-Carb': false,
    'Keto': false,
    'Paleo': false,
  };

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    districtController.dispose();
    townController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Meal'),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Name
            const Text('Meal Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter meal name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter meal description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Price
            const Text('Price (₹)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                hintText: 'Enter price',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Image selection section
            const Text('Meal Image', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // URL input field
            TextField(
              decoration: const InputDecoration(
                hintText: 'Image URL (optional)',
                border: OutlineInputBorder(),
              ),
              controller: imageUrlController,
            ),
            const SizedBox(height: 10),
            const Text('OR'),
            const SizedBox(height: 10),
            // Device storage button
            ElevatedButton.icon(
              onPressed: () async {
                // Implement image picker functionality
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    selectedImage = image;
                  });
                }
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Select from Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
              ),
            ),
            // Display selected image preview if available
            if (selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.file(
                  File(selectedImage!.path),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            
            // District
            const Text('District', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: districtController,
              decoration: const InputDecoration(
                hintText: 'Enter district',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Town
            const Text('Town', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: townController,
              decoration: const InputDecoration(
                hintText: 'Enter town',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Dietary Information
            const Text('Dietary Information', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: dietaryPreferences.keys.map((String key) {
                return FilterChip(
                  label: Text(key),
                  selected: dietaryPreferences[key]!,
                  onSelected: (bool value) {
                    setState(() {
                      dietaryPreferences[key] = value;
                    });
                  },
                  selectedColor: const Color(0xFF8BC34A).withOpacity(0.3),
                  checkmarkColor: const Color(0xFF8BC34A),
                );
              }).toList(),
            ),
            
            // Add Meal button
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8BC34A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Add Meal', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _submitMeal() {
    // Validate form
    if (nameController.text.isEmpty) {
      _showErrorSnackBar('Please enter a meal name');
      return;
    }
    
    if (priceController.text.isEmpty) {
      _showErrorSnackBar('Please enter a price');
      return;
    }
    
    if (districtController.text.isEmpty) {
      _showErrorSnackBar('Please enter a district');
      return;
    }
    
    if (townController.text.isEmpty) {
      _showErrorSnackBar('Please enter a town');
      return;
    }
    
    // Create meal object and save it
    // This is where you would typically save to a database
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal added successfully!'),
        backgroundColor: Color(0xFF8BC34A),
      ),
    );
    
    // Navigate back
    Navigator.pop(context);
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}