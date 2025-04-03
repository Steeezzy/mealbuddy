import 'package:flutter/material.dart';
import 'update_allergens_page.dart';
import 'update_diet_page.dart';
import 'update_disliked_ingredients_page.dart';

class EatingPreferencesPage extends StatelessWidget {
  const EatingPreferencesPage({super.key});

  static const Color appBarTextColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const double padding = 20.0;
  static const double fontSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreferenceItem(
              context: context,
              title: 'Diet',
              icon: Icons.restaurant_menu,
              iconColor: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
              onTap: () => _navigateTo(context, UpdateDietPage()),
            ),
            const Divider(color: dividerColor),
            _buildPreferenceItem(
              context: context,
              title: 'Allergens',
              icon: Icons.no_food,
              iconColor: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE8F4F8),
              onTap: () => _navigateTo(context, UpdateAllergensPage()),
            ),
            const Divider(color: dividerColor),
            _buildPreferenceItem(
              context: context,
              title: 'Disliked Ingredients',
              icon: Icons.clear,
              iconColor: const Color(0xFFF44336),
              backgroundColor: const Color(0xFFF9E8E8),
              onTap: () => _navigateTo(context, const UpdateDislikedIngredientsPage()),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Eating Preferences',
        style: TextStyle(
          color: appBarTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF555555)),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: fontSize,
          color: appBarTextColor,
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}