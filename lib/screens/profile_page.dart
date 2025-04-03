import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'eating_preferences_page.dart';
import 'profile_setup.dart';
import 'about_us_page.dart';
import 'dashboard.dart';
import 'user_login.dart'; // Import the login page
import 'home_page.dart'; // Add import for HomePage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color primaryColor = Color(0xFF8BC34A);
  static const double defaultPadding = 20.0;
  static const double avatarRadius = 20.0;
  
  final Map<String, dynamic> _profileData = {};
  String _displayName = "[Display Name]";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user != null) {
        final userData = await supabase
            .from('user_login')
            .select('full_name')
            .eq('user_id', user.id)
            .single();
        
        if (userData != null && userData['full_name'] != null) {
          setState(() {
            _displayName = userData['full_name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleMenuItemTap(String title) async {
    switch (title) {
      case "Edit Profile":
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetupPage()),
        );
        if (result != null && mounted) {
          setState(() => _profileData.addAll(result));
          _showSuccessMessage();
          _navigateToDashboard();
        }
        break;
      case "Eating Preferences":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EatingPreferencesPage()),
        );
        break;
      case "About Us":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutUsPage()),
        );
        break;
      case "Share MealPlanner App":
        // Implement share functionality
        break;
      case "Review in the App Store":
        // Implement review functionality
        break;
      case "Log out":
        _handleLogout();
        break;
    }
  }

  // New method to handle logout
  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Sign out from Supabase
      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();
      
      // Close loading indicator
      if (mounted) Navigator.pop(context);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Navigate to home page instead of login page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading indicator
      if (mounted) Navigator.pop(context);
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error logging out: $e');
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MealBuddyHome()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildGreeting(),
          const SizedBox(height: 40),
          ..._buildMenuItems(),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello,",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          _displayName,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    final menuItems = [
      _MenuItem("Edit Profile", Icons.person),
      _MenuItem("Eating Preferences", Icons.restaurant_menu),
      _MenuItem("About Us", Icons.info),
      _MenuItem("Share MealPlanner App", Icons.share),
      _MenuItem("Review in the App Store", Icons.star),
      _MenuItem("Log out", Icons.logout),
    ];

    return menuItems.expand((item) => [
      _buildMenuItem(item.title, item.icon),
      _buildDivider(),
    ]).toList();
  }

  Widget _buildMenuItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () => _handleMenuItemTap(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.green[100],
              child: Icon(icon, color: Colors.green),
            ),
            const SizedBox(width: defaultPadding),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
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
}

class _MenuItem {
  final String title;
  final IconData icon;

  const _MenuItem(this.title, this.icon);
}