import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/chat/chatbot_screen.dart';
import 'screens/meals/meal_details_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/add_meal_screen.dart';
import 'screens/auth/user_login_screen.dart';
import 'screens/auth/user_register_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'models/dish.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This removes the debug banner
      title: 'MealBuddy',
      theme: ThemeData(
        primaryColor: const Color(0xFF8BC34A),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8BC34A)),
        useMaterial3: true,
      ),
      home: const LandingScreen(),
      routes: {
        '/user-login': (context) => const UserLoginScreen(),
        '/user-register': (context) => const UserRegisterScreen(),
        '/user-forgot-password': (context) => const ForgotPasswordScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-forgot-password': (context) => const ForgotPasswordScreen(isAdmin: true),
        '/user-home': (context) => const UserHomeScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/add-meal': (context) => const AddMealScreen(),
        '/chatbot': (context) => const ChatBotScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/meal-details') {
          final dish = settings.arguments as Dish;
          return MaterialPageRoute(
            builder: (context) => MealDetailsScreen(dish: dish),
          );
        } else if (settings.name == '/cart') {
          final dish = settings.arguments as Dish?;
          return MaterialPageRoute(
            builder: (context) => CartScreen(initialDish: dish),
          );
        }
        return null;
      },
    );
  }
}