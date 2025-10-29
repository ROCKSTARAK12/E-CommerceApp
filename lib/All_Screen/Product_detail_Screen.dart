import 'package:e_commerce_app/All_Screen/Cart_Screen.dart';
import 'package:e_commerce_app/firestore_services.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, String> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  int _selectedImageIndex = 0;
  String _selectedColor = "White Titanium";
  String _selectedStorage = "512 GB";
  int _quantity = 1;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FirestoreService _firestoreService = FirestoreService();

  // ✅ FIXED: Now uses actual product image instead of hardcoded iPhone images
  late final List<String> _productImages;

  final Map<String, Color> _colors = {
    "Desert Titanium": const Color(0xFFD4C4B0),
    "Natural Titanium": const Color(0xFFC0C0C0),
    "White Titanium": const Color(0xFFE8E8E8),
    "Black Titanium": const Color(0xFF2C2C2C),
  };

  final List<String> _storageOptions = ["256 GB", "512 GB", "1 TB"];

  final List<Map<String, String>> _features = [
    {"icon": "📱", "title": "4K Ultra HD XDR Display"},
    {"icon": "📶", "title": "Wireless Charging System"},
    {"icon": "🔋", "title": "All-Day Battery Life"},
    {"icon": "📷", "title": "Pro Camera System"},
  ];

  @override
  void initState() {
    super.initState();

    // ✅ FIXED: Use the actual product image from the passed data
    final productImage =
        widget.product['image'] ??
        "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400";

    // Create multiple views of the same product (you can customize this per product later)
    _productImages = [productImage, productImage, productImage, productImage];

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _incrementQuantity() => setState(() => _quantity++);
  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _addToCart() async {
    final double parsedPrice =
        double.tryParse(
          widget.product['price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        ) ??
        0.0;

    final cartItem = {
      "id": widget.product['title'], // Add unique ID
      "title": widget.product['title'],
      "image": _productImages[_selectedImageIndex],
      "price": parsedPrice,
      "unit": "pcs",
      "quantity": _quantity,
      "color": _selectedColor,
      "storage": _selectedStorage,
    };

    // Add to Firestore using FirestoreService
    await _firestoreService.addToCart(cartItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Added $_quantity x ${widget.product['title']} to cart",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF9C27B0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: "VIEW CART",
            textColor: Colors.white,
            onPressed: _goToBasket,
          ),
        ),
      );
    }
  }

  void _goToBasket() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BasketScreen(cartItems: []),
      ),
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF6A1B9A)),
            onPressed: () {
              // Add to favorites functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF6A1B9A)),
            onPressed: () {
              // Share functionality
            },
          ),
          // Cart icon with badge
          StreamBuilder<int>(
            stream: _firestoreService.getCartCount(),
            builder: (context, snapshot) {
              final cartCount = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Color(0xFF6A1B9A),
                    ),
                    onPressed: _goToBasket,
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF9C27B0),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainImage(),
                _buildThumbnails(),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 16),
                      _buildPriceSection(),
                      const SizedBox(height: 24),
                      _buildColorSection(),
                      const SizedBox(height: 24),
                      _buildStorageSection(),
                      const SizedBox(height: 24),
                      _buildFeaturesSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 20),
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

  // === UI Sections ===

  Widget _buildMainImage() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9C27B0).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              _productImages[_selectedImageIndex],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_productImages.length, (index) {
          final isSelected = _selectedImageIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.all(isSelected ? 3 : 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF9C27B0)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _productImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 30,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product['title'] ?? "",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              widget.product['category'] ?? "By Brand",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFA726), size: 18),
                const SizedBox(width: 4),
                Text(
                  "${widget.product['rating'] ?? "4.8"} (2.2k)",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Text(
          widget.product['price'] ?? "₹0",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          widget.product['originalPrice'] ?? "",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE1BEE7)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                color: const Color(0xFF6A1B9A),
                onPressed: _decrementQuantity,
              ),
              Text(
                "$_quantity",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                color: const Color(0xFF6A1B9A),
                onPressed: _incrementQuantity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Color",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colors.entries.map((entry) {
            final isSelected = _selectedColor == entry.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF9C27B0) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF9C27B0)
                        : const Color(0xFFE1BEE7),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Storage",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _storageOptions.map((storage) {
            final isSelected = _selectedStorage == storage;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedStorage = storage),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF9C27B0) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF9C27B0)
                          : const Color(0xFFE1BEE7),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      storage,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "A Snapshot View",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_features.length, (index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(-20 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE1BEE7)),
              ),
              child: Row(
                children: [
                  Text(
                    _features[index]["icon"]!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _features[index]["title"]!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _goToBasket,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF9C27B0), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Go to Basket",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9C27B0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF9C27B0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Add to Cart",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
