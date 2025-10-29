import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/All_Screen/Cart_Screen.dart';
import 'package:e_commerce_app/All_Screen/Profile_Screen.dart';
import 'package:e_commerce_app/All_Screen/Search_Screen.dart';
import 'package:e_commerce_app/All_Screen/Product_Detail_Screen.dart';
import 'package:e_commerce_app/All_Screen/Wishlist_Screen.dart';
import 'package:e_commerce_app/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final FirestoreService _firestoreService = FirestoreService();

  int _selectedIndex = 0;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Widget> _pages = [
    const Center(child: Text("🏠 Home Page")),
    const WishlistScreen(),
    const BasketScreen(cartItems: []),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
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
      backgroundColor: const Color(0xFFF5F0FF),

      body: _selectedIndex == 0 ? _buildHomeContent() : _pages[_selectedIndex],

      // Purple Navigation Bar at Bottom
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.category, "Wishlist", 1),
            _navItem(Icons.shopping_cart, "Cart", 2),
            _navItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: isSelected ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 13 : 12,
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

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
        // Top Actions Bar (Search & Notification)
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Search Icon
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Color(0xFF6A1B9A),
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                  // Notification Icon
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF6A1B9A),
                      size: 28,
                    ),
                    onPressed: () {
                      // Add notification functionality
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Greeting Section
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello! 👋",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "What are you looking for today?",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Search Bar (Clickable)
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF9C27B0),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xFF9C27B0),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Search products...",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Animated Banner Carousel
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.easeInOutCubic,
                ),
                items: banners.map((banner) {
                  return Hero(
                    tag: banner,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C27B0).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          banner,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Animated Categories Header
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your favorite stores",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "See all",
                      style: TextStyle(color: Color(0xFF9C27B0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Animated Categories with Navigation
        SliverToBoxAdapter(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: _AnimatedCategoryItem(
                      category: category,
                      onTap: () {
                        // Navigate to category screen based on label
                        Widget categoryScreen;
                        switch (category['label']) {
                          case 'Mobiles':
                            categoryScreen = const MobilesScreen();
                            break;
                          case 'Laptops':
                            categoryScreen = const LaptopsScreen();
                            break;
                          case 'TVs':
                            categoryScreen = const TVsScreen();
                            break;
                          case 'Watches':
                            categoryScreen = const WatchesScreen();
                            break;
                          case 'Audio':
                            categoryScreen = const AudioScreen();
                            break;
                          case 'Appliances':
                            categoryScreen = const AppliancesScreen();
                            break;
                          default:
                            return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => categoryScreen,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Animated Products Header
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _sectionHeader("New catalogs for you"),
          ),
        ),

        // Animated Products Grid
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600 + (index * 150)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _AnimatedProductCard(
                  product: product,
                  firestoreService: _firestoreService,
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

        // Add bottom padding to avoid content hiding behind bottom nav
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
          color: Color(0xFF6A1B9A),
        ),
      ),
    );
  }
}

// Animated Category Item Widget with Navigation
class _AnimatedCategoryItem extends StatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const _AnimatedCategoryItem({required this.category, required this.onTap});

  @override
  State<_AnimatedCategoryItem> createState() => _AnimatedCategoryItemState();
}

class _AnimatedCategoryItemState extends State<_AnimatedCategoryItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE1BEE7), Color(0xFFCE93D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                child: Icon(
                  IconData(
                    widget.category['icon'] as int,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: const Color(0xFF6A1B9A),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.category['label'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6A1B9A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Product Card Widget
class _AnimatedProductCard extends StatefulWidget {
  final Map<String, String> product;
  final FirestoreService firestoreService;

  const _AnimatedProductCard({
    required this.product,
    required this.firestoreService,
  });

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isInWishlist = false;
  bool _isLoading = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _checkIfInWishlist();
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  Future<void> _checkIfInWishlist() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.product['title'])
        .get();
    if (mounted) {
      setState(() => _isInWishlist = doc.exists);
    }
  }

  Future<void> _toggleWishlist() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to use wishlist ❤️"),
          backgroundColor: Color(0xFF9C27B0),
        ),
      );
      return;
    }

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(widget.product['title']);

    setState(() => _isLoading = true);

    _heartController.forward(from: 0.0).then((_) {
      _heartController.reverse();
    });

    if (_isInWishlist) {
      await ref.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removed from wishlist 💔"),
          backgroundColor: Color(0xFF9C27B0),
        ),
      );
    } else {
      await ref.set({
        'title': widget.product['title'],
        'image': widget.product['image'],
        'price': widget.product['price'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to wishlist ❤️"),
          backgroundColor: Color(0xFF9C27B0),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isInWishlist = !_isInWishlist;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF9C27B0).withOpacity(0.3)
                    : Colors.black12,
                blurRadius: _isHovered ? 12 : 6,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Wishlist Button
              Stack(
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 110,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedBuilder(
                      animation: _heartController,
                      builder: (context, child) {
                        final scale = 0.8 + (_heartController.value * 0.4);
                        return Transform.scale(
                          scale: scale,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _toggleWishlist,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isInWishlist
                                    ? const Color(0xFF9C27B0)
                                    : Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Product Info
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
                          color: Color(0xFF6A1B9A),
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
                            color: Color(0xFFFFA726),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product['rating'] ?? "4.5",
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
                          color: Color(0xFF6A1B9A),
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
                            widget.firestoreService.addToCart(cartItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Added to cart 🛒"),
                                backgroundColor: Color(0xFF9C27B0),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBA68C8),
                            foregroundColor: Colors.white,
                            elevation: _isHovered ? 4 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text(
                            "Add to Cart",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

// ==================== CATEGORY SCREENS ====================

// Mobiles Screen
class MobilesScreen extends StatelessWidget {
  const MobilesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'iPhone 15 Pro',
        'price': '₹1,34,900',
        'image':
            'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
        'rating': '4.8',
      },
      {
        'title': 'Samsung Galaxy S24 Ultra',
        'price': '₹1,29,999',
        'image':
            'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
        'rating': '4.7',
      },
      {
        'title': 'Google Pixel 8 Pro',
        'price': '₹1,06,999',
        'image':
            'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400',
        'rating': '4.6',
      },
      {
        'title': 'OnePlus 12',
        'price': '₹64,999',
        'image':
            'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
        'rating': '4.5',
      },
      {
        'title': 'Xiaomi 14 Pro',
        'price': '₹54,999',
        'image':
            'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=400',
        'rating': '4.4',
      },
      {
        'title': 'Nothing Phone 2',
        'price': '₹44,999',
        'image':
            'https://images.unsplash.com/photo-1580910051074-3eb694886505?w=400',
        'rating': '4.3',
      },
    ];

    return _CategoryScreen(title: 'Mobiles', products: products);
  }
}

// Laptops Screen
class LaptopsScreen extends StatelessWidget {
  const LaptopsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'MacBook Pro 16"',
        'price': '₹2,49,900',
        'image':
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
        'rating': '4.9',
      },
      {
        'title': 'Dell XPS 15',
        'price': '₹1,79,990',
        'image':
            'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400',
        'rating': '4.7',
      },
      {
        'title': 'HP Spectre x360',
        'price': '₹1,49,999',
        'image':
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
        'rating': '4.6',
      },
      {
        'title': 'Lenovo ThinkPad X1',
        'price': '₹1,89,990',
        'image':
            'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400',
        'rating': '4.8',
      },
      {
        'title': 'ASUS ROG Zephyrus',
        'price': '₹2,19,990',
        'image':
            'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400',
        'rating': '4.7',
      },
      {
        'title': 'Microsoft Surface Laptop',
        'price': '₹1,69,999',
        'image':
            'https://images.unsplash.com/photo-1564182379166-8fcfdda80151?w=400',
        'rating': '4.5',
      },
    ];

    return _CategoryScreen(title: 'Laptops', products: products);
  }
}

// TVs Screen
class TVsScreen extends StatelessWidget {
  const TVsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'Samsung QLED 65"',
        'price': '₹1,29,990',
        'image':
            'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=400',
        'rating': '4.8',
      },
      {
        'title': 'LG OLED 55"',
        'price': '₹1,49,990',
        'image':
            'https://images.unsplash.com/photo-1593359863503-f598ef5f82c1?w=400',
        'rating': '4.9',
      },
      {
        'title': 'Sony Bravia 75"',
        'price': '₹2,19,990',
        'image':
            'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=400',
        'rating': '4.7',
      },
      {
        'title': 'TCL Mini-LED 65"',
        'price': '₹89,990',
        'image':
            'https://images.unsplash.com/photo-1593359863503-f598ef5f82c1?w=400',
        'rating': '4.5',
      },
      {
        'title': 'OnePlus TV 65"',
        'price': '₹69,999',
        'image':
            'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=400',
        'rating': '4.6',
      },
      {
        'title': 'Mi QLED TV 55"',
        'price': '₹54,999',
        'image':
            'https://images.unsplash.com/photo-1593359863503-f598ef5f82c1?w=400',
        'rating': '4.4',
      },
    ];

    return _CategoryScreen(title: 'TVs', products: products);
  }
}

// Watches Screen
class WatchesScreen extends StatelessWidget {
  const WatchesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'Apple Watch Series 9',
        'price': '₹45,900',
        'image':
            'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400',
        'rating': '4.8',
      },
      {
        'title': 'Samsung Galaxy Watch 6',
        'price': '₹32,999',
        'image':
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        'rating': '4.7',
      },
      {
        'title': 'Garmin Fenix 7',
        'price': '₹84,990',
        'image':
            'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=400',
        'rating': '4.9',
      },
      {
        'title': 'Fitbit Sense 2',
        'price': '₹26,999',
        'image':
            'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400',
        'rating': '4.5',
      },
      {
        'title': 'Amazfit GTR 4',
        'price': '₹17,999',
        'image':
            'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=400',
        'rating': '4.4',
      },
      {
        'title': 'Fossil Gen 6',
        'price': '₹24,995',
        'image':
            'https://images.unsplash.com/photo-1533139502658-0198f920d8e8?w=400',
        'rating': '4.3',
      },
    ];

    return _CategoryScreen(title: 'Watches', products: products);
  }
}

// Audio Screen
class AudioScreen extends StatelessWidget {
  const AudioScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'Sony WH-1000XM5',
        'price': '₹29,990',
        'image':
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        'rating': '4.9',
      },
      {
        'title': 'AirPods Pro 2',
        'price': '₹26,900',
        'image':
            'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=400',
        'rating': '4.8',
      },
      {
        'title': 'Bose QuietComfort Ultra',
        'price': '₹34,999',
        'image':
            'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=400',
        'rating': '4.7',
      },
      {
        'title': 'Sennheiser Momentum 4',
        'price': '₹31,990',
        'image':
            'https://images.unsplash.com/photo-1545127398-14699f92334b?w=400',
        'rating': '4.8',
      },
      {
        'title': 'JBL Tour Pro 2',
        'price': '₹24,999',
        'image':
            'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400',
        'rating': '4.6',
      },
      {
        'title': 'Samsung Galaxy Buds2 Pro',
        'price': '₹17,999',
        'image':
            'https://images.unsplash.com/photo-1598331668826-20cecc596b86?w=400',
        'rating': '4.5',
      },
    ];

    return _CategoryScreen(title: 'Audio', products: products);
  }
}

// Appliances Screen
class AppliancesScreen extends StatelessWidget {
  const AppliancesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'title': 'Samsung Refrigerator',
        'price': '₹54,990',
        'image':
            'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=400',
        'rating': '4.6',
      },
      {
        'title': 'LG Washing Machine',
        'price': '₹32,990',
        'image':
            'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=400',
        'rating': '4.5',
      },
      {
        'title': 'Whirlpool Microwave',
        'price': '₹12,990',
        'image':
            'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?w=400',
        'rating': '4.4',
      },
      {
        'title': 'Philips Air Fryer',
        'price': '₹9,999',
        'image':
            'https://images.unsplash.com/photo-1603046891726-36bfd957e7bd?w=400',
        'rating': '4.7',
      },
      {
        'title': 'Dyson Vacuum Cleaner',
        'price': '₹34,900',
        'image':
            'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400',
        'rating': '4.8',
      },
      {
        'title': 'Bajaj Mixer Grinder',
        'price': '₹4,999',
        'image':
            'https://images.unsplash.com/photo-1585659722983-3a675dabf23d?w=400',
        'rating': '4.3',
      },
    ];

    return _CategoryScreen(title: 'Appliances', products: products);
  }
}

// Reusable Category Screen Widget
class _CategoryScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> products;

  const _CategoryScreen({required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B9A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6A1B9A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF6A1B9A)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF6A1B9A),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _CategoryProductCard(product: product);
          },
        ),
      ),
    );
  }
}

// Category Product Card Widget
class _CategoryProductCard extends StatefulWidget {
  final Map<String, String> product;

  const _CategoryProductCard({required this.product});

  @override
  State<_CategoryProductCard> createState() => _CategoryProductCardState();
}

class _CategoryProductCardState extends State<_CategoryProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFF9C27B0).withOpacity(0.3)
                  : Colors.black12,
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                widget.product['image']!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['title']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.product['rating']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.product['price']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
