import 'package:flutter/material.dart';

class DietPreferencesScreen extends StatefulWidget {
  const DietPreferencesScreen({super.key});

  @override
  State<DietPreferencesScreen> createState() => _DietPreferencesScreenState();
}

class _DietPreferencesScreenState extends State<DietPreferencesScreen> {
  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'Gluten-Free',
    'Dairy-Free',
    'Keto',
    'Paleo',
    'Low-Carb',
    'Low-Fat',
    'High-Protein',
  ];
  
  final List<String> _allergyOptions = [
    'Nuts',
    'Dairy',
    'Eggs',
    'Soy',
    'Wheat',
    'Fish',
    'Shellfish',
    'Peanuts',
  ];
  
  List<String> _selectedDiets = ['Vegetarian'];
  List<String> _selectedAllergies = ['Nuts'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Update diet'),
        actions: [
          TextButton(
            onPressed: () {
              // Save preferences and return to previous screen
              Navigator.pop(context, {
                'diets': _selectedDiets,
                'allergies': _selectedAllergies,
              });
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dietary Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dietaryOptions.map((diet) {
                final isSelected = _selectedDiets.contains(diet);
                return FilterChip(
                  label: Text(diet),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDiets.add(diet);
                      } else {
                        _selectedDiets.remove(diet);
                      }
                    });
                  },
                  selectedColor: const Color(0xFFE8F5E9),
                  checkmarkColor: const Color(0xFF8BC34A),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Allergies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergyOptions.map((allergy) {
                final isSelected = _selectedAllergies.contains(allergy);
                return FilterChip(
                  label: Text(allergy),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add(allergy);
                      } else {
                        _selectedAllergies.remove(allergy);
                      }
                    });
                  },
                  selectedColor: const Color(0xFFFFEBEE),
                  checkmarkColor: Colors.red,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Save preferences and return to previous screen
                Navigator.pop(context, {
                  'diets': _selectedDiets,
                  'allergies': _selectedAllergies,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}