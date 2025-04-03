import 'package:flutter/material.dart';
import 'user_login.dart';
import 'admin_login.dart';
import '../widgets/meal_buddy_logo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color primaryGreen = Color(0xFF4A7C14);
  static const Color secondaryGreen = Color(0xFF8BC34A);
  static const double buttonHeight = 40.0;
  static const double fontSize = 16.0;
  static const double horizontalMargin = 30.0;
  static const double verticalMargin = 5.0;
  static const double borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MealBuddyLogo(),
          _buildLogo(),
          _buildNavigationButton(
            context: context,
            label: 'ADMIN',
            onTap: () => _navigateTo(context, const AdminLoginPage()),
          ),
          _buildNavigationButton(
            context: context,
            label: 'USER',
            onTap: () => _navigateTo(context,  SignInCreateAccountPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Meal',
              style: TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            TextSpan(
              text: 'buddy',
              style: TextStyle(
                color: secondaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: verticalMargin,
        ),
        height: buttonHeight,
        decoration: BoxDecoration(
          color: secondaryGreen,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
