import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dashboard.dart';

class ProfileSetupPage extends StatefulWidget {
  final String? userId;
  
  const ProfileSetupPage({super.key, this.userId});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  static const Color primaryColor = Color(0xFF8BC34A);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color textColor = Color(0xFF444444);
  static const Color inputFillColor = Color(0xFFF0F0F0);
  static const double defaultPadding = 20.0;
  static const double borderRadius = 4.0;
  
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  
  final Map<String, bool> _healthConditions = {
    'Diabetes': false,
    'Pre-Diabetes': false,
    'Cholesterol': false,
    'Hypertension': false,
    'PCOS': false,
    'Thyroid': false,
    'Physical Injury': false,
    'Stress/Anxiety': false,
    'Sleep Issues': false,
    'Depression': false,
    'Anger Issues': false,
    'Loneliness': false,
    'Relationship Stress': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final supabase = Supabase.instance.client;
    final userId = widget.userId ?? supabase.auth.currentUser?.id;
    
    if (userId == null) return;
    
    try {
      setState(() => _isLoading = true);
      
      final data = await supabase
          .from('user_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (data != null) {
        setState(() {
          _ageController.text = data['age']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _selectedGender = data['gender'];
          
          // Load health conditions
          final healthConditions = data['health_conditions'];
          if (healthConditions != null && healthConditions is Map) {
            healthConditions.forEach((key, value) {
              if (_healthConditions.containsKey(key)) {
                _healthConditions[key] = value;
              }
            });
          }
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final supabase = Supabase.instance.client;
    final userId = widget.userId ?? supabase.auth.currentUser?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Prepare health conditions data
      final Map<String, dynamic> healthConditionsData = {};
      _healthConditions.forEach((key, value) {
        healthConditionsData[key] = value;
      });
      
      // Prepare profile data
      final profileData = {
        'user_id': userId,
        'age': int.tryParse(_ageController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'gender': _selectedGender,
        'health_conditions': healthConditionsData,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Check if profile exists
      final existingProfile = await supabase
          .from('user_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingProfile != null) {
        // Update existing profile
        await supabase
            .from('user_profile')
            .update(profileData)
            .eq('user_id', userId);
      } else {
        // Insert new profile
        profileData['created_at'] = DateTime.now().toIso8601String();
        await supabase.from('user_profile').insert(profileData);
      }
      
      _showSuccessMessage();
      _navigateToDashboard();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
      print('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
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
      appBar: _buildAppBar(),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      title: const Text(
        'Profile Setup',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackButton(),
            const SizedBox(height: defaultPadding),
            _buildTitle(),
            const SizedBox(height: defaultPadding),
            _buildInputFields(),
            const SizedBox(height: defaultPadding),
            _buildHealthConditions(),
            const SizedBox(height: 40),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'SET UP DATA',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(_ageController, 'Age', TextInputType.number),
        const SizedBox(height: defaultPadding),
        _buildTextField(_weightController, 'Weight (kg)', TextInputType.number),
        const SizedBox(height: defaultPadding),
        _buildTextField(_heightController, 'Height (cm)', TextInputType.number),
        const SizedBox(height: defaultPadding),
        _buildGenderDropdown(),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      value: _selectedGender,
      items: ['Male', 'Female', 'Other']
          .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedGender = value),
    );
  }

  Widget _buildHealthConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Conditions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _healthConditions.keys.map(_buildHealthConditionChip).toList(),
        ),
      ],
    );
  }

  Widget _buildHealthConditionChip(String condition) {
    return ChoiceChip(
      label: Text(condition),
      selected: _healthConditions[condition]!,
      onSelected: (selected) {
        setState(() => _healthConditions[condition] = selected);
      },
      selectedColor: primaryColor.withOpacity(0.3),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: _handleUpdate,
        child: const Text(
          'UPDATE',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}