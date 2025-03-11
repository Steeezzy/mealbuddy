import 'package:flutter/material.dart';

class DashboardMealDetailsScreen extends StatelessWidget {
  const DashboardMealDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://picsum.photos/800/600',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grilled Chicken Salad',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8BC34A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '\$12.99',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nutrition Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionInfo('Calories', '450'),
                      _buildNutritionInfo('Protein', '32g'),
                      _buildNutritionInfo('Carbs', '25g'),
                      _buildNutritionInfo('Fat', '18g'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cost Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCostItem('Chicken Breast', 5.99),
                  _buildCostItem('Fresh Vegetables', 3.50),
                  _buildCostItem('Dressing', 1.50),
                  _buildCostItem('Other Ingredients', 2.00),
                  const Divider(),
                  _buildCostItem('Total', 12.99, isTotal: true),
                  const SizedBox(height: 24),
                  const Text(
                    'Verified Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildReviewItem(),
                  _buildReviewItem(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCostItem(String item, double cost, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${cost.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF8BC34A) : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage('https://picsum.photos/200'),
                ),
                const SizedBox(width: 8),
                const Text(
                  'John Doe',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < 4 ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFD700),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'The salad was fresh and delicious. The chicken was perfectly grilled and the dressing complemented the vegetables well. Would definitely order again!',
            ),
            const SizedBox(height: 8),
            const Text(
              '2 days ago',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}