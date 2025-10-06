import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFF00B761),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildOrderItem('ORD-123456', 'Delivered', '₹1,249', 'Sep 25, 2024', [
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=100',
          ], true),
          _buildOrderItem('ORD-123455', 'Delivered', '₹899', 'Sep 20, 2024', [
            'https://images.unsplash.com/photo-1563241527-3004b7be0ffd?w=100',
          ], false),
          _buildOrderItem('ORD-123454', 'Cancelled', '₹1,599', 'Sep 15, 2024', [
            'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=100',
          ], false),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    String orderId,
    String status,
    String amount,
    String date,
    List<String> images,
    bool isLatest,
  ) {
    Color statusColor = status == 'Delivered'
        ? Colors.green
        : status == 'Cancelled'
        ? Colors.red
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$orderId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Placed on $date'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 40,
                  child: Row(
                    children: images
                        .map(
                          (image) => Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLatest)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Reorder'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: const Text('Rate Order'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
