import 'package:e_commerce_app/All_Screen/Cart_Screen.dart';
import 'package:e_commerce_app/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  final FirestoreService _firestoreService = FirestoreService();

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("🏠 Home Page")),
    const Center(child: Text("🛍️ Categories")),
    const CartScreen(),
    const Center(child: Text("👤 Profile")),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showAppBarTitle = _scrollController.offset > 80;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFEF),

      // ✅ Switch between Home content and other pages
      body: _selectedIndex == 0 ? _buildHomeContent() : _pages[_selectedIndex],

      // ✅ Floating Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.category, "Categories", 1),
            _navItem(Icons.shopping_cart, "Cart", 2),
            _navItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  // 🔘 Floating Nav Item Widget
  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.greenAccent : Colors.white,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.greenAccent : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Your full Home page content
  Widget _buildHomeContent() {
    final banners = [
      "https://imgs.search.brave.com/JVP8Om_KQNyCa0bLHv6O_Z_LEXZLLT8dezp6rqumqus/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/cHJlbWl1bS12ZWN0/b3IvZ3JhZGllbnQt/c2FsZS1iYWNrZ3Jv/dW5kXzIzLTIxNDkw/MzgxMjYuanBnP3Nl/bXQ9YWlzX2h5YnJp/ZCZ3PTc0MCZxPTgw",
      "https://imgs.search.brave.com/iI5XFYMYXfZ_BAALiNpKxoSa5_RdzZ-mxRMPsRiLKLs/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMubWFjcnVtb3Jz/LmNvbS90L0h4MVgz/Q2pyYXpIME1QUTh0/cDNzX0hsUFR3OD0v/NDAweDAvYXJ0aWNs/ZS1uZXcvMjAyNS8w/Ni9pUGhvbmUtMTct/QmFzZS1Nb2RlbC1S/dW1vcmVkLXRvLUNv/bWUtaW4tTmV3LUdy/ZWVuLWFuZC1QdXJw/bGUtQ29sb3JzLUZl/YXR1cmUuanBnP2xv/c3N5",
      "https://imgs.search.brave.com/PnYEkIo4pHtRbYwgVXzy5NbLhJW1mjBiFwrM9RsHeG4/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/bW9zLmNtcy5mdXR1/cmVjZG4ubmV0L2Q4/R3NNN2VBZ3VkcVlK/WG5YS0xNSlguanBn",
    ];

    final categories = [
      {"icon": Icons.phone_iphone.codePoint, "label": "Mobiles"},
      {"icon": Icons.laptop.codePoint, "label": "Laptops"},
      {"icon": Icons.tv.codePoint, "label": "TVs"},
      {"icon": Icons.watch.codePoint, "label": "Watches"},
      {"icon": Icons.headphones.codePoint, "label": "Audio"},
      {"icon": Icons.kitchen.codePoint, "label": "Appliances"},
    ];

    final products = [
      {
        "title": "Apple MacBook Pro 14-inch",
        "image":
            "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400",
        "price": "₹1,59,999",
        "originalPrice": "₹1,99,999",
        "discount": "20% off",
        "rating": "4.5",
      },
      {
        "title": "iPhone 17 Pro Max",
        "image":
            "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400",
        "price": "₹1,29,999",
        "originalPrice": "₹1,79,999",
        "discount": "20% off",
        "rating": "4.7",
      },
      {
        "title": "ASUS Vivobook S16",
        "image":
            "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400",
        "price": "₹54,999",
        "originalPrice": "₹64,999",
        "discount": "15% off",
        "rating": "4.3",
      },
      {
        "title": "New Balance 550",
        "image":
            "https://imgs.search.brave.com/rfD3cd6JxBDEIiv4sfg46Bo3MeMi71WZghJThJtaExk/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9zbmVh/a2VybmV3cy5jb20v/d3AtY29udGVudC91/cGxvYWRzLzIwMjUv/MDMvbmV3LWJhbGFu/Y2UtNTUwLXNlYS1z/YWx0LWJsYWNrLUJC/NTUwTEVHLTMuanBn/P3c9NTQwJmg9Mzgw/JmNyb3A9MQ",
        "price": "₹29,999",
        "originalPrice": "₹34,999",
        "discount": "14% off",
        "rating": "4.6",
      },
    ];

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 🔥 Banner Carousel
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              items: banners.map((banner) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    banner,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // 🔥 Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Your favorite stores",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text("See all", style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          IconData(
                            category['icon'] as int,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category['label'] as String,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // 🔥 Recommended Products Grid
        SliverToBoxAdapter(child: _sectionHeader("New catalogs for you")),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        product['image']!,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title']!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product['rating']!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              product['price']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final cartItem = {
                                    "title": product['title'],
                                    "image": product['image'],
                                    "price": int.parse(
                                      product['price']!.replaceAll(
                                        RegExp(r'[^0-9]'),
                                        '',
                                      ),
                                    ),
                                    "unit": "pcs",
                                    "quantity": 1,
                                  };
                                  _firestoreService.addToCart(cartItem);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Added to cart"),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    99,
                                    228,
                                    103,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Add",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }, childCount: products.length),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
