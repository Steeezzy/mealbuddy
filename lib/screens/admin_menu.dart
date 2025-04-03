import 'package:flutter/material.dart';
import 'package:mealb/auth/auth_service.dart';
import 'home_page.dart';
import 'about_us_page.dart';
import 'admin_edit_profile.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  static const Color primaryColor = Color.fromARGB(255, 139, 195, 74);
  static const Color backgroundColor = Color(0xFFF0F0F0);
  static const Color menuIconBgColor = Color(0xFFD0E6C4);
  static const double spacing = 10.0;
  static const double padding = 20.0;
  
  String _restaurantName = 'Loading...';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRestaurantName();
  }
  
  Future<void> _loadRestaurantName() async {
    try {
      final authService = AuthService();
      final profileData = await authService.getCurrentUserProfile();
      
      setState(() {
        _restaurantName = profileData?['resto_name'] ?? 'Restaurant Name';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _restaurantName = 'Restaurant Name';
        _isLoading = false;
      });
      print('Error loading restaurant name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(padding),
        child: Column(
          children: [
            _buildMenuItem(
              context: context,
              icon: Icons.edit,
              label: 'Edit Profile',
              onTap: () => _navigateToEditProfile(context),
            ),
            const SizedBox(height: spacing),
            _buildDivider(),
            const SizedBox(height: spacing),
            _buildMenuItem(
              context: context,
              icon: Icons.info,
              label: 'About Us',
              onTap: () => _navigateToAboutUs(context),
            ),
            const SizedBox(height: spacing),
            _buildDivider(),
            const SizedBox(height: spacing),
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              label: 'Log out',
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      title: _isLoading
          ? const Row(
              children: [
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ],
            )
          : Text(
              _restaurantName,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[300],
      thickness: 1,
      height: 1,
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: menuIconBgColor,
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            const SizedBox(width: padding),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final authService = AuthService();
      
      // Get current user's profile data
      final profileData = await authService.getCurrentUserProfile();
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (profileData != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminEditProfileScreen(
              restoName: profileData['resto_name'] ?? '',
              state: profileData['state'] ?? '',
              district: profileData['district'] ?? '',
              city: profileData['city'] ?? '',
              imageUrl: profileData['image_url'], // Add the image URL
            ),
          ),
        );
        
        // Refresh restaurant name if profile was updated
        if (result == true) {
          _loadRestaurantName();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
      print('Error in _navigateToEditProfile: $e'); // Add detailed logging
    }
  }

  void _navigateToAboutUs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutUsPage()),
    );
  }

  void _handleLogout(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Create an instance of AuthService
      final authService = AuthService();
      
      // Call the signOut method
      await authService.signOut();
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Navigate to home page and clear navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }
}