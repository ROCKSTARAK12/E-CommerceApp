import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  /// 🔹 Get all products (main collection se)
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

  /// 🔹 Get today’s deals
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

  /// 🔹 Get categories
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

  /// 🔹 Get products of a specific category
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

  /// 🔹 Add product to cart
  Future<void> addToCart(Map<String, dynamic> product) async {
    if (uid == null) return;

    final cartRef = _db.collection("users").doc(uid).collection("cart");

    // Agar product already cart me hai toh qty increase kare
    final existing = await cartRef.where("id", isEqualTo: product["id"]).get();

    if (existing.docs.isNotEmpty) {
      final docId = existing.docs.first.id;
      final currentQty = (existing.docs.first["quantity"] ?? 1) as int;
      await cartRef.doc(docId).update({"quantity": currentQty + 1});
    } else {
      // Price ko numeric store karna best practice hai
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

      await cartRef.add({...product, "price": price, "quantity": 1});
    }
  }

  /// 🔹 Get cart count (badge ke liye)
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

  /// 🔹 Get all cart items
  Stream<List<Map<String, dynamic>>> getCartItems() {
    if (uid == null) return const Stream.empty();
    return _db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {"docId": doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// 🔹 Update quantity of item
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
      await cartRef.delete(); // agar qty 0 ho toh remove kar do
    }
  }

  /// 🔹 Remove item from cart
  Future<void> removeFromCart(String docId) async {
    if (uid == null) return;
    await _db
        .collection("users")
        .doc(uid)
        .collection("cart")
        .doc(docId)
        .delete();
  }
}
