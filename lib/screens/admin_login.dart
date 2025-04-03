import 'package:flutter/material.dart';
import 'package:mealb/auth/auth_service.dart';
import 'admin_dashboard.dart';
import 'admin_create_account.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  static const Color primaryColor = Color(0xFF8BC34A);
  static const Color backgroundColor = Color(0xFFF0F0F0);
  static const double spacing = 20.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(spacing),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: _buildLoginCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const SizedBox(height: spacing),
          const Text(
            "Admin Sign In",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: spacing),
          _buildEmailField(),
          const SizedBox(height: spacing),
          _buildPasswordField(),
          const SizedBox(height: spacing),
          _buildSignInButton(),
          // Removed the _buildForgotPassword() widget and spacing
          const SizedBox(height: 40),
          _buildCreateAccountSection(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(Icons.arrow_back, size: 30, color: Colors.grey.shade600),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      "Email",
      "Enter your email",
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      "Password",
      "Enter your password",
      controller: _passwordController,
      obscureText: !_passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _passwordVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return _buildButton(
      "Sign In",
      Colors.green,  // Changed from primaryColor to match user login
      onPressed: _handleSignIn,
    );
  }

  // Remove the _buildForgotPassword() method entirely
  
  Widget _buildCreateAccountSection() {
    return Container(
      padding: const EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(
            "Don't have an admin account?",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          _buildButton(
            "Create Admin Account",
            const Color(0xFF90EE90),
            onPressed: _handleCreateAccount,
            borderColor: primaryColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color color, {
    required VoidCallback onPressed,
    Color borderColor = Colors.transparent,
    Color? textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final response = await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (response.user != null) {
        // Navigate to dashboard on successful login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _handleCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminCreateAccountPage()),
    );
  }
}