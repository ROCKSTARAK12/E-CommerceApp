import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get uid => _auth.currentUser?.uid;

  // ============================
  // 📦 PRODUCT METHODS
  // ============================

  Stream<List<Map<String, dynamic>>> getProducts() {
    return _db
        .collection("products")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), "id": doc.id})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getTodayDeals() {
    return _db
        .collection("todayDeals")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), "id": doc.id})
              .toList(),
        );
  }

  // ============================
  // 📂 CATEGORY METHODS
  // ============================

  Stream<List<Map<String, dynamic>>> getCategories() {
    return _db
        .collection("categories")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), "id": doc.id})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getCategoryProducts(String categoryName) {
    return _db
        .collection("categories")
        .doc(categoryName)
        .collection("products")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {"id": doc.id, ...doc.data()})
              .toList(),
        );
  }

  // ============================
  // 🛒 CART METHODS
  // ============================

  /// ✅ FIXED: Add product uniquely, increment only if same title+image exist
  Future<void> addToCart(Map<String, dynamic> product) async {
    if (uid == null) return;

    final cartRef = _db.collection("users").doc(uid).collection("cart");

    // Check if an identical product (by title + image) exists
    final existing = await cartRef
        .where("title", isEqualTo: product["title"])
        .where("image", isEqualTo: product["image"])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Product exists — increase quantity
      final docId = existing.docs.first.id;
      final currentQty = (existing.docs.first["quantity"] ?? 1) as int;
      await cartRef.doc(docId).update({"quantity": currentQty + 1});
    } else {
      // New product — add to cart
      num price = 0;
      if (product["price"] is String) {
        price =
            num.tryParse(
              (product["price"] as String).replaceAll(RegExp(r'[^0-9.]'), ""),
            ) ??
            0;
      } else if (product["price"] is num) {
        price = product["price"];
      }

      await cartRef.add({
        ...product,
        "price": price,
        "quantity": product["quantity"] ?? 1,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get cart items count (for badge display)
  Stream<int> getCartCount() {
    if (uid == null) return const Stream.empty();
    return _db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.fold<int>(
            0,
            (sum, doc) => sum + ((doc["quantity"] ?? 0) as int),
          ),
        );
  }

  /// Get all cart items as a stream
  Stream<List<Map<String, dynamic>>> getCartItems() {
    if (uid == null) return const Stream.empty();
    return _db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {"docId": doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Update quantity of a cart item
  Future<void> updateCartQuantity(String docId, int newQty) async {
    if (uid == null) return;
    final cartRef = _db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(docId);

    if (newQty > 0) {
      await cartRef.update({"quantity": newQty});
    } else {
      await cartRef.delete(); // Remove if quantity is 0
    }
  }

  /// Remove an item from cart
  Future<void> removeFromCart(String docId) async {
    if (uid == null) return;
    await _db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(docId)
        .delete();
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    if (uid == null) return;
    final cartRef = _db.collection("users").doc(uid).collection("cart");
    final snapshot = await cartRef.get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ============================
  // 📊 ORDER METHODS
  // ============================

  Future<String?> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required Map<String, dynamic> shippingAddress,
  }) async {
    if (uid == null) return null;

    try {
      final orderRef = await _db.collection("orders").add({
        "userId": uid,
        "items": items,
        "totalAmount": totalAmount,
        "shippingAddress": shippingAddress,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await clearCart(); // Clear cart after placing order
      return orderRef.id;
    } catch (e) {
      print("Error creating order: $e");
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getUserOrders() {
    if (uid == null) return const Stream.empty();
    return _db
        .collection("orders")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {"orderId": doc.id, ...doc.data()})
              .toList(),
        );
  }
}
