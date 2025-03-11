import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _phoneController = TextEditingController(text: '(123) 456-7890');
  final _addressController = TextEditingController(text: '123 Main St, City, State');
  
  List<String> _dietaryPreferences = ['Vegetarian'];
  List<String> _allergies = ['Nuts'];
  
  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
  ];
  
  final List<String> _allergyOptions = [
    'Nuts',
    'Dairy',
    'Eggs',
    'Soy',
    'Wheat',
    'Shellfish',
    'Fish',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF8BC34A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFEEF7E6),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF8BC34A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Implement photo upload
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Change Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Text(
              'Dietary Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _dietaryOptions.map((option) {
                final isSelected = _dietaryPreferences.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: const Color(0xFFDCEDC8),
                  checkmarkColor: const Color(0xFF8BC34A),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _dietaryPreferences.add(option);
                      } else {
                        _dietaryPreferences.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Allergies',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allergyOptions.map((option) {
                final isSelected = _allergies.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFCDD2),
                  checkmarkColor: Colors.red,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _allergies.add(option);
                      } else {
                        _allergies.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Color(0xFF8BC34A),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Profile Menu Items
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF8BC34A)),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.restaurant_menu, color: Color(0xFF8BC34A)),
                    title: const Text('Diet Preferences'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, '/diet-preferences'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.support_agent, color: Color(0xFF8BC34A)),
                    title: const Text('Support Center'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(context, '/support'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout'),
                    onTap: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

