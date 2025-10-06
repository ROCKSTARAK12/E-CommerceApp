import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required String categoryName});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Fruits & Vegetables',
        'icon': Icons.apple,
        'color': Colors.red,
        'items': 45,
      },
      {
        'name': 'Dairy & Bread',
        'icon': Icons.local_dining,
        'color': Colors.amber,
        'items': 32,
      },
      {
        'name': 'Snacks & Beverages',
        'icon': Icons.local_cafe,
        'color': Colors.blue,
        'items': 78,
      },
      {
        'name': 'Home Care',
        'icon': Icons.home,
        'color': Colors.green,
        'items': 56,
      },
      {
        'name': 'Personal Care',
        'icon': Icons.person,
        'color': Colors.purple,
        'items': 67,
      },
      {
        'name': 'Baby Care',
        'icon': Icons.child_care,
        'color': Colors.pink,
        'items': 23,
      },
      {
        'name': 'Pet Care',
        'icon': Icons.pets,
        'color': Colors.brown,
        'items': 15,
      },
      {
        'name': 'Medicines',
        'icon': Icons.medical_services,
        'color': Colors.teal,
        'items': 89,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoriesScreen(
                    categoryName: category['name'] as String,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category['color'] as Color,
                      (category['color'] as Color).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category['items']} items',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
