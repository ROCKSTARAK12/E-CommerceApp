import 'dart:async';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<String> recentSearches = ["Laundry", "Chocolate", "Shoes", "Maxi paid"];

  final stores = [
    {"icon": Icons.shopping_bag, "label": "E-Bazar"},
    {"icon": Icons.store, "label": "On-Shop"},
    {"icon": Icons.local_mall, "label": "e-Order"},
    {"icon": Icons.shopping_cart, "label": "W-Store"},
    {"icon": Icons.storefront, "label": "Creative"},
  ];

  final List<Map<String, String>> popularSearches = [
    {
      "title": "Carrefour",
      "subtitle": "Children's chocolate",
      "image":
          "https://images.unsplash.com/photo-1607082350899-7e105aa886ae?auto=format&fit=crop&w=200&q=80",
    },
    {
      "title": "Intermarché Hyper",
      "subtitle": "Paper toilet",
      "image":
          "https://images.unsplash.com/photo-1580910051074-7d4ebf4a30f3?auto=format&fit=crop&w=200&q=80",
    },
    {
      "title": "Carrefour Market",
      "subtitle": "The laughing cow",
      "image":
          "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=200&q=80",
    },
    {
      "title": "Carrefour",
      "subtitle": "Semi-skimmed milk",
      "image":
          "https://images.unsplash.com/photo-1604908177522-d1b9f5a4c7c8?auto=format&fit=crop&w=200&q=80",
    },
    {
      "title": "Super U",
      "subtitle": "Fresh vegetables",
      "image":
          "https://images.unsplash.com/photo-1604908554039-6ef8892e4b3c?auto=format&fit=crop&w=200&q=80",
    },
    {
      "title": "Carrefour",
      "subtitle": "Yogurt pack",
      "image":
          "https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?auto=format&fit=crop&w=200&q=80",
    },
  ];

  String query = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        setState(() {
          query = _searchController.text.trim().toLowerCase();
        });
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _searchItem(String value) {
    _searchController.text = value;
    setState(() {
      query = value.toLowerCase();
      if (value.isNotEmpty && !recentSearches.contains(value)) {
        recentSearches.insert(0, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredResults = popularSearches.where((item) {
      final title = item["title"]!.toLowerCase();
      final subtitle = item["subtitle"]!.toLowerCase();
      return title.contains(query) || subtitle.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFFFEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFFFEF),
        elevation: 0,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onSubmitted: _searchItem,
            decoration: const InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔥 Recent Searches (Clickable)
          if (recentSearches.isNotEmpty) ...[
            const Text(
              "Recent Searches",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: recentSearches.map((search) {
                return InputChip(
                  label: Text(search),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () => _searchItem(search),
                  onDeleted: () {
                    setState(() {
                      recentSearches.remove(search);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // 🔥 Favorite Stores (Clickable)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Your favorite stores",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("See all", style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return InkWell(
                  onTap: () => _searchItem(store["label"] as String),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            store["icon"] as IconData,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          store["label"] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 Popular Searches / Results
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Popular Searches",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("See all", style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),

          if (filteredResults.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "No results found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.8,
              ),
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final item = filteredResults[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item["image"]!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item["title"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["subtitle"]!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
