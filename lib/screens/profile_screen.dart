import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealbuddy/screens/edit_profile_screen.dart';
import 'package:mealbuddy/screens/eating_preferences_screen.dart';
import 'package:mealbuddy/screens/about_us_screen.dart';
import 'package:mealbuddy/screens/contact_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = '[Display Name]';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Thank you banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF8BC34A),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thank you for supporting us!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'As a local business, we thank you for supporting us and hope you enjoy.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Profile options
              _buildProfileOption(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  _navigateToEditProfile();
                },
              ),
              
              _buildProfileOption(
                icon: Icons.restaurant_menu,
                title: 'Eating Preferences',
                onTap: () {
                  _navigateToEatingPreferences();
                },
              ),
              
              _buildProfileOption(
                icon: Icons.info_outline,
                title: 'About Us',
                onTap: () {
                  _navigateToAboutUs();
                },
              ),
              
              _buildProfileOption(
                icon: Icons.email_outlined,
                title: 'Contact Us',
                onTap: () {
                  _navigateToContactUs();
                },
              ),
              
              _buildProfileOption(
                icon: Icons.share,
                title: 'Share MealBuddy App',
                onTap: () {
                  _shareApp();
                },
              ),
              
              _buildProfileOption(
                icon: Icons.star_border,
                title: 'Review in the App Store',
                onTap: () {
                  _reviewApp();
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF8BC34A),
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // Profile tab is selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Try a simpler approach - just pop the current screen
            Navigator.of(context).pop();
            
            // Show a message to indicate the action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Going to Meals screen...')),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2D9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF8BC34A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  
  // Navigation methods
  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    
    if (result != null && result is String) {
      setState(() {
        displayName = result;
      });
    }
  }
  
  void _navigateToEatingPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EatingPreferencesScreen()),
    );
  }
  
  void _navigateToAboutUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutUsScreen()),
    );
  }
  
  // Remove the _navigateToSupportCenter method since we're not using it
  
  void _navigateToContactUs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactUsScreen()),
    );
  }
  
  void _shareApp() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing app...')),
    );
  }
  
  void _reviewApp() {
    // Implement app review functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening App Store for review...')),
    );
  }
}

