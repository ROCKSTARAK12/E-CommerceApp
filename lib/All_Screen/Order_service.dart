import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderService {
  // Save a new order
  static Future<bool> saveOrder({
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    String? deliveryAddress,
    String status = 'Confirmed',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Generate Order ID
      final orderId =
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Format date
      final dateFormat = DateFormat('MMM dd, yyyy');
      final orderDate = dateFormat.format(DateTime.now());

      // Calculate total items
      int totalItems = 0;
      for (var item in cartItems) {
        totalItems += (item['quantity'] as int? ?? 1);
      }

      // Create order object
      final order = {
        'id': orderId,
        'date': orderDate,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': status,
        'total': totalAmount,
        'items': totalItems,
        'products': cartItems
            .map(
              (item) => {
                'name': item['name'] ?? item['title'] ?? 'Product',
                'quantity': item['quantity'] ?? 1,
                'price': item['price'] ?? 0.0,
                'image': item['image'] ?? item['imageUrl'] ?? '',
              },
            )
            .toList(),
        'deliveryAddress': deliveryAddress,
      };

      // Get existing orders
      final String? ordersJson = prefs.getString('order_history');
      List<Map<String, dynamic>> orders = [];

      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        orders = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      // Add new order at the beginning
      orders.insert(0, order);

      // Save back to preferences
      final String updatedOrdersJson = json.encode(orders);
      await prefs.setString('order_history', updatedOrdersJson);

      return true;
    } catch (e) {
      print('Error saving order: $e');
      return false;
    }
  }

  // Get all orders
  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ordersJson = prefs.getString('order_history');

      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      return [];
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  // Update order status
  static Future<bool> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? ordersJson = prefs.getString('order_history');

      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        List<Map<String, dynamic>> orders = decoded
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        // Find and update the order
        for (var order in orders) {
          if (order['id'] == orderId) {
            order['status'] = newStatus;
            break;
          }
        }

        // Save back
        final String updatedOrdersJson = json.encode(orders);
        await prefs.setString('order_history', updatedOrdersJson);

        return true;
      }

      return false;
    } catch (e) {
      print('Error updating order: $e');
      return false;
    }
  }

  // Clear all orders (for testing)
  static Future<void> clearAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('order_history');
  }
}
