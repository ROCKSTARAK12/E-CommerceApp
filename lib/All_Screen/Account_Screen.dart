import 'package:e_commerce_app/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce_app/auth/auth_sevices.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // User Info Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF00B761),
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'Guest User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '+91 9876543210',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepOrange),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Account Options
          _buildListTile(
            'My Orders',
            Icons.shopping_bag,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildListTile(
            'Addresses',
            Icons.location_on,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildListTile(
            'Payment Methods',
            Icons.payment,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildListTile(
            'Wishlist',
            Icons.favorite_border,
            Icons.arrow_forward_ios,
            () {},
          ),

          const SizedBox(height: 16),

          // Support
          _buildListTile(
            'Help Center',
            Icons.help,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildListTile(
            'Customer Support',
            Icons.support_agent,
            Icons.arrow_forward_ios,
            () {},
          ),

          const SizedBox(height: 16),

          // Legal
          _buildListTile(
            'Terms of Service',
            Icons.description,
            Icons.arrow_forward_ios,
            () {},
          ),
          _buildListTile(
            'Privacy Policy',
            Icons.privacy_tip,
            Icons.arrow_forward_ios,
            () {},
          ),

          const SizedBox(height: 24),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData leadingIcon,
    IconData trailingIcon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(leadingIcon, color: Colors.deepOrange),
      title: Text(title),
      trailing: Icon(trailingIcon, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
