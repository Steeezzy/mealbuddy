import 'package:flutter/material.dart';
import '../services/eating_preferences_service.dart';

class UpdateDislikedIngredientsPage extends StatefulWidget {
  const UpdateDislikedIngredientsPage({super.key});

  @override
  State<UpdateDislikedIngredientsPage> createState() => _UpdateDislikedIngredientsPageState();
}

class _UpdateDislikedIngredientsPageState extends State<UpdateDislikedIngredientsPage> {
  static const Color primaryColor = Color(0xFF8BC34A);
  static const double defaultPadding = 20.0;
  static const double buttonHeight = 45.0;
  
  static const List<String> ingredients = [
    'Onions',
    'Mushrooms',
    'Bell Peppers',
    'Cilantro',
    'Garlic',
    'Tomatoes',
    'Olives',
    'Eggplant'
  ];
  
  final List<String> selectedIngredients = [];
  bool _isLoading = true;
  final EatingPreferencesService _preferencesService = EatingPreferencesService();

  @override
  void initState() {
    super.initState();
    _loadCurrentIngredients();
  }

  Future<void> _loadCurrentIngredients() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _preferencesService.getUserPreferences();
      if (prefs != null && prefs['disliked_ingredients'] != null) {
        final ingredients = List<String>.from(prefs['disliked_ingredients']);
        setState(() {
          selectedIngredients.clear();
          selectedIngredients.addAll(ingredients);
        });
      }
    } catch (e) {
      print('Error loading disliked ingredients: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
    });
  }

  Future<void> _handleUpdate(BuildContext context) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _preferencesService.updateDislikedIngredients(selectedIngredients);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disliked ingredients updated successfully'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, selectedIngredients);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update disliked ingredients'),
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
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Update Disliked Ingredients',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Expanded(child: _buildIngredientsList()),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    return ListView.builder(
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: IngredientOption(
            ingredient: ingredient,
            isSelected: selectedIngredients.contains(ingredient),
            onTap: () => _toggleIngredient(ingredient),
          ),
        );
      },
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.5),
        ),
        minimumSize: Size(double.infinity, buttonHeight),
      ),
      onPressed: () => _handleUpdate(context),
      child: const Text(
        'Update',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class IngredientOption extends StatelessWidget {
  final String ingredient;
  final bool isSelected;
  final VoidCallback onTap;

  const IngredientOption({
    super.key,
    required this.ingredient,
    required this.isSelected,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF8BC34A);
  static const double optionHeight = 45.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: optionHeight,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
          border: isSelected ? Border.all(color: primaryColor) : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ingredient,
              style: TextStyle(
                fontSize: 14,
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