import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShoppingAddressScreen extends StatefulWidget {
  const ShoppingAddressScreen({super.key});

  @override
  State<ShoppingAddressScreen> createState() => _ShoppingAddressScreenState();
}

class _ShoppingAddressScreenState extends State<ShoppingAddressScreen> {
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  // 🔹 Load all addresses from SharedPreferences
  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('addresses');
    if (jsonStr != null) {
      final List list = json.decode(jsonStr);
      setState(() => _addresses = List<Map<String, dynamic>>.from(list));
    }
  }

  // 🔹 Save addresses + ensure a default address is stored separately
  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();

    // If no address is default, automatically mark the first one
    if (_addresses.isNotEmpty &&
        !_addresses.any((a) => a['isDefault'] == true)) {
      _addresses[0]['isDefault'] = true;
    }

    // Save all addresses
    await prefs.setString('addresses', json.encode(_addresses));

    // Save the default address separately for Profile screen
    final defaultAddr = _addresses.firstWhere(
      (a) => a['isDefault'] == true,
      orElse: () => {},
    );

    if (defaultAddr.isNotEmpty) {
      await prefs.setString('default_address', json.encode(defaultAddr));
    }
  }

  // 🔹 Add or Edit address dialog
  void _addOrEditAddress({Map<String, dynamic>? existing}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddressDialog(existing: existing),
    );

    if (result != null) {
      setState(() {
        if (existing != null) {
          final index = _addresses.indexOf(existing);
          _addresses[index] = result;
        } else {
          _addresses.add(result);
        }
      });
      await _saveAddresses();
    }
  }

  // 🔹 Delete an address
  void _deleteAddress(Map<String, dynamic> address) async {
    setState(() => _addresses.remove(address));
    await _saveAddresses();
  }

  // 🔹 Set an address as default
  void _setDefault(Map<String, dynamic> address) async {
    setState(() {
      for (var a in _addresses) {
        a['isDefault'] = false;
      }
      address['isDefault'] = true;
    });
    await _saveAddresses();
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
        title: const Text(
          "Shopping Address",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: _addresses.isEmpty
          ? const Center(
              child: Text(
                "No saved addresses yet.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final addr = _addresses[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      addr['address'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${addr['postcode']}, ${addr['city']}, ${addr['country']}",
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _addOrEditAddress(existing: addr);
                        } else if (value == 'delete') {
                          _deleteAddress(addr);
                        } else if (value == 'default') {
                          _setDefault(addr);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text("Edit")),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete"),
                        ),
                        if (addr['isDefault'] != true)
                          const PopupMenuItem(
                            value: 'default',
                            child: Text("Set as Default"),
                          ),
                      ],
                    ),
                    leading: Icon(
                      addr['isDefault'] == true
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: addr['isDefault'] == true
                          ? Colors.purple
                          : Colors.grey,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditAddress(),
        backgroundColor: const Color(0xFF9C27B0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 🔹 Address Dialog for Add/Edit
class _AddressDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const _AddressDialog({this.existing});

  @override
  State<_AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<_AddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  final _postcode = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _address.text = widget.existing!['address'] ?? '';
      _postcode.text = widget.existing!['postcode'] ?? '';
      _city.text = widget.existing!['city'] ?? '';
      _country.text = widget.existing!['country'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing != null ? "Edit Address" : "Add Address"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildField("Street Address", _address),
              const SizedBox(height: 10),
              _buildField("Postal Code", _postcode),
              const SizedBox(height: 10),
              _buildField("City", _city),
              const SizedBox(height: 10),
              _buildField("Country", _country),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'address': _address.text.trim(),
                'postcode': _postcode.text.trim(),
                'city': _city.text.trim(),
                'country': _country.text.trim(),
                'isDefault': widget.existing?['isDefault'] ?? false,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C27B0),
          ),
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
    );
  }
}
