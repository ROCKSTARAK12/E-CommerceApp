class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;

  CartManager._internal();

  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> product) {
    final index = _cartItems.indexWhere(
      (item) => item['title'] == product['title'],
    );
    if (index != -1) {
      _cartItems[index]['quantity'] += product['quantity'];
    } else {
      _cartItems.add({...product});
    }
  }

  void clearCart() => _cartItems.clear();

  void addItem(item) {}
}
