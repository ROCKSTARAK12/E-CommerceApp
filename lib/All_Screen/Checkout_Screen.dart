import 'order_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_commerce_app/All_Screen/Orders_Screen.dart';
import 'dart:convert';
import 'dart:async';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String selectedPaymentMethod = "visa";
  bool isProcessing = false;

  Map<String, dynamic>? defaultAddress;
  List<Map<String, dynamic>> allAddresses = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    _loadAddresses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('addresses');
    if (jsonStr != null) {
      final List list = json.decode(jsonStr);
      allAddresses = List<Map<String, dynamic>>.from(list);
    }

    final defaultStr = prefs.getString('default_address');
    if (defaultStr != null) {
      defaultAddress = json.decode(defaultStr);
    } else if (allAddresses.isNotEmpty) {
      defaultAddress = allAddresses.first;
    }
    setState(() {});
  }

  Future<void> _setDefaultAddress(Map<String, dynamic> address) async {
    final prefs = await SharedPreferences.getInstance();

    for (var a in allAddresses) {
      a['isDefault'] = false;
    }
    address['isDefault'] = true;
    defaultAddress = address;

    await prefs.setString('addresses', json.encode(allAddresses));
    await prefs.setString('default_address', json.encode(defaultAddress!));
    setState(() {});
  }

  void _showAddressPicker() {
    if (allAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No saved addresses. Please add one first."),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Delivery Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...allAddresses.map((addr) {
                bool isSelected = addr['isDefault'] == true;
                return GestureDetector(
                  onTap: () async {
                    await _setDefaultAddress(addr);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.purple.shade50 : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.purple
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected ? Colors.purple : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${addr['address'] ?? ''}, ${addr['postcode'] ?? ''}, ${addr['city'] ?? ''}, ${addr['country'] ?? ''}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/shopping-address').then((_) {
                    _loadAddresses();
                  });
                },
                child: const Text(
                  "Add New Address",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initiatePayment() async {
    if (defaultAddress == null) {
      _showErrorDialog("Please add a delivery address before proceeding.");
      return;
    }

    setState(() => isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Always success for all payment methods
    bool paymentSuccess = true;

    setState(() => isProcessing = false);

    if (paymentSuccess) {
      await _saveOrder();
    }
  }

  Future<void> _saveOrder() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
      ),
    );

    final deliveryAddress =
        "${defaultAddress?['address'] ?? ''}, ${defaultAddress?['postcode'] ?? ''}, ${defaultAddress?['city'] ?? ''}, ${defaultAddress?['country'] ?? ''}";

    bool success = await OrderService.saveOrder(
      cartItems: widget.cartItems,
      totalAmount: widget.totalAmount,
      deliveryAddress: deliveryAddress,
      status: 'Confirmed',
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog("Failed to save order. Please try again.");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Animation Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),

            // Success Text
            const Text(
              "Payment Successful!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              "Your order has been placed successfully",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Order Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Amount",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  Text(
                    "₹${widget.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Go to Orders Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Close the success dialog
                  Navigator.pop(context);
                  // Close the checkout screen
                  Navigator.pop(context);
                  // Navigate to Order History Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View My Orders",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Continue Shopping Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Close the success dialog
                  Navigator.pop(context);
                  // Close the checkout screen and go back to home
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Continue Shopping",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.error_outline, color: Colors.red, size: 60),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildContent()),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B9A)),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Center(
            child: Text(
              "Checkout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );

  Widget _buildContent() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        _buildShippingInfo(),
        const SizedBox(height: 24),
        _buildPaymentOptions(),
      ],
    ),
  );

  Widget _buildShippingInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Shipping information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          TextButton(
            onPressed: _showAddressPicker,
            child: const Text(
              "Change",
              style: TextStyle(color: Color(0xFF6366F1), fontSize: 14),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _infoCard([
        _infoRow(Icons.person_outline, "Aksha"),
        _infoRow(
          Icons.location_on_outlined,
          defaultAddress != null
              ? "${defaultAddress?['address'] ?? ''}\n${defaultAddress?['postcode'] ?? ''}, ${defaultAddress?['city'] ?? ''}, ${defaultAddress?['country'] ?? ''}"
              : "No address saved yet.",
        ),
      ]),
    ],
  );

  Widget _infoCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: List.generate(children.length * 2 - 1, (i) {
        if (i.isEven) return children[i ~/ 2];
        return const SizedBox(height: 12);
      }),
    ),
  );

  Widget _infoRow(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.grey.shade600, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    ],
  );

  Widget _buildPaymentOptions() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Payment Method",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 16),
      _infoCard([
        _paymentOption(
          "visa",
          "Visa Card",
          "**** **** **** 1234",
          Colors.indigoAccent,
        ),
        _paymentOption(
          "mastercard",
          "Mastercard",
          "**** **** **** 9876",
          Colors.redAccent,
        ),
        _paymentOption(
          "bank",
          "Bank Transfer",
          "**** **** **** 4321",
          Colors.blue,
        ),
      ]),
    ],
  );

  Widget _paymentOption(String id, String name, String number, Color color) {
    bool selected = selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.purple : Colors.grey,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Icon(Icons.credit_card, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Text(
              "₹${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing ? null : initiatePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Confirm and Pay",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}
