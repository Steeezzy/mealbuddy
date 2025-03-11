// Replace Firebase Firestore with mock data
import 'package:flutter/material.dart';
import '../../models/admin_dish.dart';

class LocationBasedMealsScreen extends StatefulWidget {
  const LocationBasedMealsScreen({super.key});

  @override
  State<LocationBasedMealsScreen> createState() => _LocationBasedMealsScreenState();
}

class _LocationBasedMealsScreenState extends State<LocationBasedMealsScreen> {
  String _selectedDistrict = 'Ernakulam';
  String _selectedTown = 'Kochi';
  bool _sortByHighToLow = false;
  List<AdminDish> _dishes = [];
  bool _isLoading = true;

  final Map<String, List<String>> _keralaDistricts = {
    'Ernakulam': ['Kochi', 'Aluva', 'Angamaly', 'Perumbavoor'],
    'Thrissur': ['Thrissur City', 'Chalakudy', 'Guruvayur', 'Kunnamkulam'],
    'Kozhikode': ['Kozhikode City', 'Vadakara', 'Koyilandy', 'Ramanattukara'],
    // Add more districts and towns
  };

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
            isAvailable: true,
          ),
          AdminDish(
            id: '2',
            name: 'Appam with Stew',
            description: 'Soft rice pancakes with vegetable stew',
            price: 120.0,
            imageUrl: 'https://example.com/appam.jpg',
            district: 'Ernakulam',
            town: 'Kochi',
            isAvailable: true,
          ),
          AdminDish(
            id: '3',
            name: 'Malabar Biryani',
            description: 'Aromatic rice dish with spices and meat',
            price: 180.0,
            imageUrl: 'https://example.com/biryani.jpg',
            district: 'Kozhikode',
            town: 'Kozhikode City',
            isAvailable: true,
          ),
          AdminDish(
            id: '4',
            name: 'Puttu and Kadala Curry',
            description: 'Steamed rice cake with black chickpea curry',
            price: 90.0,
            imageUrl: 'https://example.com/puttu.jpg',
            district: 'Thrissur',
            town: 'Thrissur City',
            isAvailable: true,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  List<AdminDish> get _filteredDishes {
    List<AdminDish> filtered = _dishes
        .where((dish) => 
            dish.district == _selectedDistrict && 
            dish.town == _selectedTown && 
            dish.isAvailable)
        .toList();
    
    filtered.sort((a, b) => _sortByHighToLow 
        ? b.price.compareTo(a.price) 
        : a.price.compareTo(b.price));
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Meals'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    decoration: const InputDecoration(labelText: 'District'),
                    items: _keralaDistricts.keys.map((String district) {
                      return DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDistrict = newValue!;
                        _selectedTown = _keralaDistricts[_selectedDistrict]![0];
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTown,
                    decoration: const InputDecoration(labelText: 'Town'),
                    items: _keralaDistricts[_selectedDistrict]!.map((String town) {
                      return DropdownMenuItem(
                        value: town,
                        child: Text(town),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTown = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filteredDishes.isEmpty
                    ? const Center(child: Text('No meals available in this location'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredDishes.length,
                        itemBuilder: (context, index) {
                          final dish = _filteredDishes[index];
                          return GestureDetector(
                            onTap: () => _showDishDetails(context, dish),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          dish.imageUrl,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 120,
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                dish.town,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dish.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${dish.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dish.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFilters(context),
        label: const Text('Filter'),
        icon: const Icon(Icons.filter_list),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showDishDetails(BuildContext context, AdminDish dish) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 1.0,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  dish.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 60, color: Colors.grey),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${dish.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dish.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context, 
                            '/cart',
                            arguments: dish,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Price: Low to High'),
                onTap: () {
                  setModalState(() {
                    _sortByHighToLow = false;
                  });
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Price: High to Low'),
                onTap: () {
                  setModalState(() {
                    _sortByHighToLow = true;
                  });
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}