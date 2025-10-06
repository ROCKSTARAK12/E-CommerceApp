import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    // Dummy product list (replace with Firestore or API later)
    final products = [
      {
        "name": "New Balance 327 Sneakers For Men",
        "image": "assets\images\sneakers_img.png",
        "rating": 4.2,
        "reviews": 905,
        "oldPrice": 9999,
        "price": 4299,
        "offerPrice": 3869,
        "discount": 57,
        "delivery": "30th Sep",
      },
      {
        "name": "New Balance 327 Sneakers For Men",
        "image": "assets\images\sneakers_img.png",
        "rating": 4.2,
        "reviews": 905,
        "oldPrice": 9999,
        "price": 4299,
        "offerPrice": 3869,
        "discount": 57,
        "delivery": "28th Sep",
      },
      {
        "name": "New Balance 574 Sneakers For Men",
        "image": "assets\images\sneakers_img.png",
        "rating": 4.3,
        "reviews": 3000,
        "oldPrice": 9999,
        "price": 4300,
        "offerPrice": 3870,
        "discount": 56,
        "delivery": "29th Sep",
      },
      {
        "name": "New Balance 574 Legacy Sneakers For Men",
        "image": "assets\images\sneakers_img.png",
        "rating": 3.9,
        "reviews": 11,
        "oldPrice": 11999,
        "price": 5160,
        "offerPrice": 4644,
        "discount": 56,
        "delivery": "1st Oct",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: TextEditingController(text: query),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            hintText: "Search for products",
            border: InputBorder.none,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "3",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image + Wishlist
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.network(
                  product["image"],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 14,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.favorite_border, size: 16),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),

          // Rating
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        product["rating"].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.white, size: 12),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${product["reviews"]}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // Product Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(height: 4),

          // Price + Discount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  "₹${product["price"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "₹${product["oldPrice"]}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${product["discount"]}% off",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Bank Offer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "₹${product["offerPrice"]} with Bank offer",
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),

          // Delivery Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              "Delivery by ${product["delivery"]}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
