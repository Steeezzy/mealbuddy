import 'package:flutter/material.dart';
import '../../models/admin_dish.dart';

class AdminDishScreen extends StatefulWidget {
  const AdminDishScreen({super.key});

  @override
  State<AdminDishScreen> createState() => _AdminDishScreenState();
}

class _AdminDishScreenState extends State<AdminDishScreen> {
  List<AdminDish> _dishes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  void _loadDishes() {
    // Mock data instead of Firestore
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _dishes = [
          AdminDish(
            id: '1',
            name: 'Kerala Sadya',
            description: 'Traditional Kerala feast served on banana leaf',
            price: 250.0,
            imageUrl: 'https://example.com/sadya.jpg',
            district: 'Ernakulam',
            town: 'Kochi',
          ),
          AdminDish(
            id: '2',
            name: 'Appam with Stew',
            description: 'Soft rice pancakes with vegetable stew',
            price: 120.0,
            imageUrl: 'https://example.com/appam.jpg',
            district: 'Ernakulam',
            town: 'Kochi',
          ),
          AdminDish(
            id: '3',
            name: 'Malabar Biryani',
            description: 'Aromatic rice dish with spices and meat',
            price: 180.0,
            imageUrl: 'https://example.com/biryani.jpg',
            district: 'Kozhikode',
            town: 'Kozhikode City',
          ),
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Dishes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDishDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dishes.isEmpty
              ? const Center(child: Text('No dishes available'))
              : ListView.builder(
                  itemCount: _dishes.length,
                  itemBuilder: (context, index) {
                    final dish = _dishes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Image.network(
                          dish.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant, size: 25, color: Colors.grey),
                            );
                          },
                        ),
                        title: Text(dish.name),
                        subtitle: Text(
                          '₹${dish.price.toStringAsFixed(2)} - ${dish.town}, ${dish.district}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showAddEditDishDialog(context, dish),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteDish(context, dish),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddEditDishDialog(BuildContext context, [AdminDish? dish]) {
    final nameController = TextEditingController(text: dish?.name ?? '');
    final descriptionController = TextEditingController(text: dish?.description ?? '');
    final priceController = TextEditingController(text: dish?.price.toString() ?? '');
    final imageUrlController = TextEditingController(text: dish?.imageUrl ?? '');
    final districtController = TextEditingController(text: dish?.district ?? '');
    final townController = TextEditingController(text: dish?.town ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dish == null ? 'Add New Dish' : 'Edit Dish'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: districtController,
                decoration: const InputDecoration(labelText: 'District'),
              ),
              TextField(
                controller: townController,
                decoration: const InputDecoration(labelText: 'Town'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newDish = AdminDish(
                id: dish?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                imageUrl: imageUrlController.text,
                district: districtController.text,
                town: townController.text,
              );

              setState(() {
                if (dish == null) {
                  _dishes.add(newDish);
                } else {
                  final index = _dishes.indexWhere((d) => d.id == dish.id);
                  if (index >= 0) {
                    _dishes[index] = newDish;
                  }
                }
              });

              Navigator.pop(context);
            },
            child: Text(dish == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDish(BuildContext context, AdminDish dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dish'),
        content: Text('Are you sure you want to delete "${dish.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _dishes.removeWhere((d) => d.id == dish.id);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}