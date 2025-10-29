import 'package:flutter/material.dart';
import 'package:e_commerce_app/All_Screen/Product_Detail_Screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredProducts = [];
  bool _isSearching = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // All available products in the store
  final List<Map<String, String>> _allProducts = [
    {
      "title": "Apple iPad Air",
      "image":
          "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400",
      "price": "₹57,900",
      "category": "Tablets",
      "rating": "4.8",
    },
    {
      "title": "Apple Watch Series 9",
      "image":
          "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400",
      "price": "₹41,900",
      "category": "Watches",
      "rating": "4.7",
    },
    {
      "title": "Apple MacBook Pro 14-inch",
      "image":
          "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400",
      "price": "₹1,59,999",
      "category": "Laptops",
      "rating": "4.9",
    },
    {
      "title": "Apple iPhone 15 Pro Max",
      "image":
          "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400",
      "price": "₹1,29,999",
      "category": "Mobiles",
      "rating": "4.8",
    },
    {
      "title": "Apple iPad Pro 12.9",
      "image":
          "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400",
      "price": "₹87,900",
      "category": "Tablets",
      "rating": "4.9",
    },
    {
      "title": "Apple MacBook Air M2",
      "image":
          "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400",
      "price": "₹99,900",
      "category": "Laptops",
      "rating": "4.8",
    },
    {
      "title": "Apple AirPods Pro",
      "image":
          "https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=400",
      "price": "₹24,900",
      "category": "Audio",
      "rating": "4.6",
    },
    {
      "title": "Apple iMac 24-inch",
      "image":
          "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400",
      "price": "₹1,34,900",
      "category": "Computers",
      "rating": "4.7",
    },
    {
      "title": "Apple TV 4K",
      "image":
          "https://images.unsplash.com/photo-1593784991095-a205069470b6?w=400",
      "price": "₹14,900",
      "category": "Entertainment",
      "rating": "4.5",
    },
    {
      "title": "Apple Pencil 2nd Gen",
      "image":
          "https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400",
      "price": "₹11,900",
      "category": "Accessories",
      "rating": "4.7",
    },
    {
      "title": "Samsung Galaxy S24 Ultra",
      "image":
          "https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400",
      "price": "₹1,19,999",
      "category": "Mobiles",
      "rating": "4.6",
    },
    {
      "title": "Sony WH-1000XM5",
      "image":
          "https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=400",
      "price": "₹29,990",
      "category": "Audio",
      "rating": "4.8",
    },
    {
      "title": "Dell XPS 15",
      "image":
          "https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400",
      "price": "₹1,45,990",
      "category": "Laptops",
      "rating": "4.7",
    },
    {
      "title": "iPad Mini 6th Gen",
      "image":
          "https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400",
      "price": "₹46,900",
      "category": "Tablets",
      "rating": "4.6",
    },
    {
      "title": "Apple Watch Ultra",
      "image":
          "https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400",
      "price": "₹89,900",
      "category": "Watches",
      "rating": "4.9",
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = [];

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
      if (_isSearching) {
        _fadeController.forward();
        _filteredProducts = _allProducts
            .where(
              (product) => product['title']!.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();
      } else {
        _fadeController.reverse();
        _filteredProducts = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Results
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B9A)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),

          // Search Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF9C27B0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search products...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9C27B0),
                    size: 24,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF9C27B0),
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF6A1B9A)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 100,
            color: const Color(0xFF9C27B0).withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            "Search for products",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6A1B9A).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try searching for phones, laptops, tablets...",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: const Color(0xFF9C27B0).withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              "No results found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6A1B9A).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try searching with different keywords",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              "Found ${_filteredProducts.length} result${_filteredProducts.length == 1 ? '' : 's'}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
          ),
        ),

        // Products Grid
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72, // ✅ FIXED: Increased from 0.7 to 0.72
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: _buildProductCard(product),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image - ✅ FIXED: Reduced height from 140 to 130
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 130, // Changed from 140
                width: double.infinity,
                color: const Color(0xFFF5F0FF),
                child: Image.network(
                  product['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Product Details - ✅ FIXED: Optimized padding and spacing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0), // Reduced from 12
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ✅ ADDED
                  children: [
                    // Product Name
                    Text(
                      product['title']!,
                      style: const TextStyle(
                        fontSize: 13, // Reduced from 14
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A1B9A),
                        height: 1.2, // ✅ ADDED: Tighter line height
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3), // Reduced from 4
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 13, // Reduced from 14
                          color: Color(0xFFFFA726),
                        ),
                        const SizedBox(width: 3), // Reduced from 4
                        Text(
                          product['rating']!,
                          style: const TextStyle(
                            fontSize: 11, // Reduced from 12
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price
                    Text(
                      product['price']!,
                      style: const TextStyle(
                        fontSize: 15, // Reduced from 16
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C27B0),
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
