import 'package:flutter/material.dart';
import 'package:mealb/auth/auth_service.dart';
import 'admin_login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Import for kIsWeb

class AdminCreateAccountPage extends StatefulWidget {
  const AdminCreateAccountPage({super.key});

  @override
  State<AdminCreateAccountPage> createState() => _AdminCreateAccountPageState();
}

class _AdminCreateAccountPageState extends State<AdminCreateAccountPage> {
  final authService = AuthService();
  bool _passwordVisible = false;
  bool _verifyPasswordVisible = false;

  final TextEditingController _restoNameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyPasswordController = TextEditingController();

  // Add image related variables
  File? _selectedImage;
  String? _imageUrl;
  String? _imagePath;

  static const Color primaryColor = Color(0xFF8BC34A);
  static const Color backgroundColor = Color(0xFFF0F0F0);
  static const Color textColor = Color(0xFF333333);
  static const Color appBarColor = Color(0xFFF8F8F8);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void dispose() {
    _restoNameController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: appBarColor,
      title: const Text(
        'Create Admin Account',
        style: TextStyle(color: Color(0xFF444444), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildForm(),
            const SizedBox(height: 40),
            _buildCreateAccountButton(),
            const SizedBox(height: 20),
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Create an admin account',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  // Add these fields to the class
  String? _selectedState;
  String? _selectedDistrict;
  final List<String> _states = ['Kerala'];

  // Add this helper method
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

  Widget _buildForm() {
    return Column(
      children: [
        // Add photo upload at the top of the form
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
        _buildTextField('Resto Name', _restoNameController),
        // Replace state TextField with dropdown
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
              _stateController.text = newValue ?? '';
            });
          },
        ),
        // Replace district TextField with dropdown
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
                    _districtController.text = newValue ?? '';
                  });
                }
              : null,
          hintText: 'Select state first',
        ),
        _buildTextField('City/Town', _cityController),
        _buildTextField('Email', _emailController),
        _buildPasswordField('Password', _passwordController, _passwordVisible, 
          () => setState(() => _passwordVisible = !_passwordVisible)),
        _buildPasswordField('Verify Password', _verifyPasswordController, _verifyPasswordVisible,
          () => setState(() => _verifyPasswordVisible = !_verifyPasswordVisible)),
      ],
    );
  }

  // Add this new method for dropdown fields
  Widget _buildDropdownField(
    String label,
    String? value,
    List<DropdownMenuItem<String>> items,
    Function(String?)? onChanged, {
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
        items: items,
        onChanged: onChanged,
        hint: hintText != null ? Text(hintText) : null,
      ),
    );
  }
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: _handleCreateAccount,
        child: const Text(
          'Create Account',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return const Center(
      child: Text(
        'By clicking "Create Account," you agree to MealPlanner\'s Terms of Use.',
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handleCreateAccount() async {
    // Validate inputs
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _restoNameController.text.isEmpty ||
        _selectedState == null ||
        _selectedDistrict == null ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    
    // Validate password match
    if (_passwordController.text != _verifyPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Create account in Supabase
      final response = await authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (response.user != null) {
        // Store restaurant profile data
        await authService.storeRestaurantProfile(
          restoName: _restoNameController.text.trim(),
          state: _selectedState!,
          district: _selectedDistrict!,
          city: _cityController.text.trim(),
          email: _emailController.text.trim(),
          imagePath: _imagePath, // Add the image path
        );
        
        // Close loading dialog
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        
        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminLoginPage()),
          (route) => false,
        );
      } else {
        // Close loading dialog
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create account')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}