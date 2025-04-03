import 'package:flutter/material.dart';

class MealPlansScreen extends StatefulWidget {
  @override
  _MealPlansScreenState createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  String selectedMealTime = 'Breakfast';  // Default selected meal time

  // Meal plans data
  final Map<String, List<Map<String, String>>> mealPlans = {
    'Breakfast': [
      {'name': 'Masala Dosa', 'restaurant': 'South Indian Kitchen', 'location': 'Pala, Kottayam', 'price': '80'},
      {'name': 'Idli Sambar', 'restaurant': 'Kerala Kitchen', 'location': 'Kakkanad, Ernakulam', 'price': '60'},
    ],
    'Lunch': [
      {'name': 'Kerala Meals', 'restaurant': 'Rahmath', 'location': 'Pala, Kottayam', 'price': '120'},
      {'name': 'North Indian Thali', 'restaurant': 'Food Court', 'location': 'Kakkanad, Ernakulam', 'price': '150'},
    ],
    'Dinner': [
      {'name': 'Chicken Biriyani', 'restaurant': 'Al Reem', 'location': 'Pala, Kottayam', 'price': '160'},
      {'name': 'Porotta & Beef', 'restaurant': 'Royal Kitchen', 'location': 'Kakkanad, Ernakulam', 'price': '140'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Column(
          children: const [
            Text(
              'MealBuddy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Affordable, healthy meals near you',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Meal Time Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Breakfast', 'Lunch', 'Dinner'].map((mealTime) {
                  bool isSelected = selectedMealTime == mealTime;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.lightGreen : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.black87,
                      elevation: isSelected ? 2 : 0,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedMealTime = mealTime;
                      });
                    },
                    child: Text(mealTime),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Meal Cards based on selected meal time
            ...mealPlans[selectedMealTime]!.map((meal) => 
              MealCard(
                mealName: meal['name']!,
                restoName: meal['restaurant']!,
                location: meal['location']!,
                price: meal['price']!,
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String mealName;
  final String restoName;
  final String location;
  final String price;

  const MealCard({
    required this.mealName,
    required this.restoName,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mealName, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey, size: 60),
          ),
          const SizedBox(height: 12),
          Text(restoName, 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 4),
          Text(location, 
            style: const TextStyle(fontSize: 14, color: Colors.grey)
          ),
          const SizedBox(height: 8),
          Text(
            "₹$price",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.lightGreen,
            ),
          ),
        ],
      ),
    );
  }
}