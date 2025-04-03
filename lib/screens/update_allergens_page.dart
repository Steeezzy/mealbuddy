import 'package:flutter/material.dart';
import '../services/eating_preferences_service.dart';

class UpdateAllergensPage extends StatefulWidget {
  const UpdateAllergensPage({super.key});

  @override
  State<UpdateAllergensPage> createState() => _UpdateAllergensPageState();
}

class _UpdateAllergensPageState extends State<UpdateAllergensPage> {
  static const Color primaryColor = Color(0xFF8BC34A);
  static const double defaultPadding = 20.0;
  static const double buttonHeight = 45.0;
  
  static const List<String> _allergenTypes = [
    'Peanuts',
    'Tree Nuts',
    'Milk',
    'Eggs',
    'Fish',
    'Shellfish',
    'Soy',
    'Wheat'
  ];
  
  final List<String> _selectedAllergens = [];
  bool _isLoading = true;
  final EatingPreferencesService _preferencesService = EatingPreferencesService();

  @override
  void initState() {
    super.initState();
    _loadCurrentAllergens();
  }

  Future<void> _loadCurrentAllergens() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _preferencesService.getUserPreferences();
      if (prefs != null && prefs['allergens'] != null) {
        final allergens = List<String>.from(prefs['allergens']);
        setState(() {
          _selectedAllergens.clear();
          _selectedAllergens.addAll(allergens);
        });
      }
    } catch (e) {
      print('Error loading allergens: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleAllergen(String allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
      }
    });
  }

  Future<void> _handleUpdate(BuildContext context) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _preferencesService.updateAllergens(_selectedAllergens);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Allergens updated successfully'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, _selectedAllergens);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update allergens'),
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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Update allergens',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildAllergensList()),
          const SizedBox(height: defaultPadding),
          _buildUpdateButton(context),
        ],
      ),
    );
  }

  Widget _buildAllergensList() {
    return ListView.builder(
      itemCount: _allergenTypes.length,
      itemBuilder: (context, index) {
        final allergen = _allergenTypes[index];
        final isSelected = _selectedAllergens.contains(allergen);
        return AllergenOption(
          allergen: allergen,
          isSelected: isSelected,
          onTap: () => _toggleAllergen(allergen),
        );
      },
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () => _handleUpdate(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.5),
          ),
        ),
        child: const Text(
          'Update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AllergenOption extends StatelessWidget {
  final String allergen;
  final bool isSelected;
  final VoidCallback onTap;

  const AllergenOption({
    super.key,
    required this.allergen,
    required this.isSelected,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF8BC34A);
  static const double optionHeight = 45.0;
  static const double borderRadius = 5.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
          height: optionHeight,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius),
            border: isSelected ? Border.all(color: primaryColor) : null,
          ),
          child: ListTile(
            title: Text(
              allergen,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: primaryColor)
                : null,
          ),
        ),
      ),
    );
  }
}