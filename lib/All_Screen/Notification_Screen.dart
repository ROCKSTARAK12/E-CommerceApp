import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newsletter = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Order Delivered',
      'message': 'Your order #ORD-001234 has been delivered successfully',
      'time': '2 hours ago',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'isRead': false,
    },
    {
      'title': 'Order Shipped',
      'message': 'Your order #ORD-001233 is on the way',
      'time': '5 hours ago',
      'icon': Icons.local_shipping,
      'color': Colors.orange,
      'isRead': false,
    },
    {
      'title': 'Special Offer',
      'message': 'Get 20% off on all electronics. Limited time offer!',
      'time': '1 day ago',
      'icon': Icons.local_offer,
      'color': Colors.purple,
      'isRead': true,
    },
    {
      'title': 'Payment Successful',
      'message': 'Payment of £89.99 was successful',
      'time': '2 days ago',
      'icon': Icons.payment,
      'color': Colors.blue,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B9A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                ),
              );
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Color(0xFF9C27B0)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Settings Section
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Notification Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsToggle(
                    'Push Notifications',
                    'Receive push notifications on your device',
                    _pushNotifications,
                    (value) => setState(() => _pushNotifications = value),
                  ),
                  const Divider(height: 24),
                  _buildSettingsToggle(
                    'Email Notifications',
                    'Receive notifications via email',
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                  const Divider(height: 24),
                  _buildSettingsToggle(
                    'Order Updates',
                    'Get updates about your orders',
                    _orderUpdates,
                    (value) => setState(() => _orderUpdates = value),
                  ),
                  const Divider(height: 24),
                  _buildSettingsToggle(
                    'Promotions & Offers',
                    'Receive special offers and discounts',
                    _promotions,
                    (value) => setState(() => _promotions = value),
                  ),
                  const Divider(height: 24),
                  _buildSettingsToggle(
                    'Newsletter',
                    'Subscribe to our weekly newsletter',
                    _newsletter,
                    (value) => setState(() => _newsletter = value),
                  ),
                ],
              ),
            ),

            // Recent Notifications Section
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Recent',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotificationCard(_notifications[index], index),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF9C27B0),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    return Dismissible(
      key: Key(notification['title'] + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${notification['title']} dismissed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.insert(index, notification);
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            notification['isRead'] = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification['isRead']
                ? Colors.white
                : const Color(0xFFE1BEE7).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: notification['isRead']
                ? null
                : Border.all(color: const Color(0xFF9C27B0).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification['isRead']
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification['isRead'])
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9C27B0),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
