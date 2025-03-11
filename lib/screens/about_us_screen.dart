import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MealBuddy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8BC34A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'MealBuddy is a mini project developed by students of SJCET Palai.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Team Members:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTeamMember('Alen Vincent'),
            _buildTeamMember('Ajun K Saji'),
            _buildTeamMember('John Joseph'),
            _buildTeamMember('Karthik J'),
            const SizedBox(height: 24),
            const Text(
              'From SJCET Palai as a part of mini project.',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.person, color: Color(0xFF8BC34A)),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}