import 'package:flutter/material.dart';

class EatingPreferencesScreen extends StatefulWidget {
  const EatingPreferencesScreen({super.key});

  @override
  State<EatingPreferencesScreen> createState() => _EatingPreferencesScreenState();
}

class _EatingPreferencesScreenState extends State<EatingPreferencesScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eating Preferences'),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Select your dietary preferences:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...dietaryPreferences.keys.map((String preference) {
            return CheckboxListTile(
              title: Text(preference),
              value: dietaryPreferences[preference],
              activeColor: const Color(0xFF8BC34A),
              onChanged: (bool? value) {
                setState(() {
                  dietaryPreferences[preference] = value ?? false;
                });
              },
            );
          }).toList(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Save preferences
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8BC34A),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'Save Preferences',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}