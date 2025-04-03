import 'package:flutter/material.dart';
import '../services/eating_preferences_service.dart';

class UpdateDietPage extends StatefulWidget {
  const UpdateDietPage({super.key});

  @override
  State<UpdateDietPage> createState() => _UpdateDietPageState();
}

class _UpdateDietPageState extends State<UpdateDietPage> {
  static const Color primaryColor = Color(0xFF8BC34A);
  static const double defaultPadding = 20.0;
  static const List<String> dietTypes = ['Vegetarian', 'Vegan', 'Keto', 'Paleo'];
  
  String? selectedDiet;
  bool _isLoading = true;
  final EatingPreferencesService _preferencesService = EatingPreferencesService();

  @override
  void initState() {
    super.initState();
    _loadCurrentPreference();
  }

  Future<void> _loadCurrentPreference() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _preferencesService.getUserPreferences();
      if (prefs != null && prefs['diet_preference'] != null) {
        setState(() {
          selectedDiet = prefs['diet_preference'];
        });
      }
    } catch (e) {
      print('Error loading diet preference: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDiet(BuildContext context) async {
    // Check if a diet is selected
    if (selectedDiet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a diet preference'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final success = await _preferencesService.updateDietPreference(selectedDiet);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diet preference updated to $selectedDiet'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, selectedDiet);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update diet preference'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Update Diet'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          const SizedBox(height: defaultPadding),
          _buildDietOptions(),
          const SizedBox(height: 30),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildDietOptions() {
    return Column(
      children: [
        for (String dietType in dietTypes)
          DietOption(
            dietType: dietType,
            isSelected: dietType == selectedDiet,
            onTap: () => setState(() => selectedDiet = dietType),
          ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: () => _updateDiet(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Update',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}

class DietOption extends StatelessWidget {
  final String dietType;
  final bool isSelected;
  final VoidCallback onTap;

  const DietOption({
    super.key,
    required this.dietType,
    required this.isSelected,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF8BC34A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: primaryColor, width: 2)
            : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dietType,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: primaryColor),
          ],
        ),
      ),
    );
  }
}