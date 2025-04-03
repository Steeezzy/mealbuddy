import 'package:flutter/material.dart';
import 'package:mealb/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

class AdminEditProfileScreen extends StatefulWidget {
  final String restoName;
  final String state;
  final String district;
  final String city;
  final String? imageUrl; // Add imageUrl parameter

  const AdminEditProfileScreen({
    super.key,
    required this.restoName,
    required this.state,
    required this.district,
    required this.city,
    this.imageUrl, // Add this parameter
  });

  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  final authService = AuthService();
  
  late final TextEditingController _restoNameController;
  late final TextEditingController _cityController;
  
  String? _selectedState;
  String? _selectedDistrict;
  
  // Add image related variables
  File? _selectedImage;
  String? _imageUrl;
  String? _imagePath;
  
  bool _isLoading = false;
  
  final List<String> _states = ['Kerala'];

  static const Color primaryColor = Color(0xFF8BC34A);
  static const Color backgroundColor = Color(0xFFF0F0F0);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    _restoNameController = TextEditingController(text: widget.restoName);
    _cityController = TextEditingController(text: widget.city);
    
    // Set initial dropdown values
    _selectedState = widget.state;
    _selectedDistrict = widget.district;
    
    // Set initial image URL
    _imageUrl = widget.imageUrl;
    _imagePath = widget.imageUrl;
  }

  @override
  void dispose() {
    _restoNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

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
          Text('Upload Logo', style: TextStyle(fontSize: 12, color: Colors.blue)),
        ],
      ),
    );
  }

  // Get districts based on state
  List<String> _getDistricts(String state) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF8BC34A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Restaurant Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Add photo upload at the top
              Center(
                child: Column(
                  children: [
                    _buildPhotoUpload(),
                    const SizedBox(height: 10),
                    const Text(
                      'Restaurant Logo',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField('Restaurant Name', _restoNameController),
              const SizedBox(height: 16),
              _buildDropdownField(
                'State',
                _selectedState,
                _states.map((state) => DropdownMenuItem(
                  value: state,
                  child: Text(state),
                )).toList(),
                (newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _selectedDistrict = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                'District',
                _selectedDistrict,
                _selectedState != null
                    ? _getDistricts(_selectedState!).map((district) => DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        )).toList()
                    : [],
                _selectedState != null
                    ? (newValue) {
                        setState(() {
                          _selectedDistrict = newValue;
                        });
                      }
                    : null,
                hintText: 'Select state first',
              ),
              const SizedBox(height: 16),
              _buildTextField('City/Town', _cityController),
              const SizedBox(height: 30),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?)? onChanged, {
    String? hintText,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
      ),
      items: items,
      onChanged: onChanged,
      hint: hintText != null ? Text(hintText) : null,
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8BC34A),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: _isLoading ? null : _handleUpdateProfile,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Update Profile',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
      ),
    );
  }

  void _handleUpdateProfile() async {
    // Validate inputs
    if (_restoNameController.text.isEmpty ||
        _selectedState == null ||
        _selectedDistrict == null ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update profile in database with image path
      final success = await authService.updateRestaurantProfile(
        restoName: _restoNameController.text.trim(),
        state: _selectedState!,
        district: _selectedDistrict!,
        city: _cityController.text.trim(),
        imagePath: _imagePath, // Add image path to update
      );

      setState(() {
        _isLoading = false;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        // Return true to indicate successful update
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      print('Exception during update: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}