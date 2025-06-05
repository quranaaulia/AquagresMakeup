import 'package:tugasakhirtpm/models/makeup.dart';
import 'package:tugasakhirtpm/models/notifikasi.dart';
import 'package:tugasakhirtpm/screens/home.dart';
import 'package:tugasakhirtpm/models/helpnotifikasi.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<Checkout> {
  late Box<CartItem> cartBox;
  String currentUser = '';
  String selectedPaymentMethod = '';
  bool isAddressConfirmed = false;

  // Controllers for address input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Pastel color palette - sama dengan CartPage
  final Color primaryPurple = const Color(0xFFB19CD9);
  final Color secondaryBlue = const Color(0xFF8EC5FC);
  final Color accentPink = const Color(0xFFE0C3FC);
  final Color softWhite = const Color(0xFFF8F9FA);

  final List<Map<String, dynamic>> paymentMethods = [
    {'name': 'PayLater', 'icon': Icons.schedule},
    {'name': 'QRIS', 'icon': Icons.qr_code},
    {'name': 'Debit Payment', 'icon': Icons.payment},
    {'name': 'Credit Card', 'icon': Icons.credit_card},
  ];

  @override
  void initState() {
    super.initState();
    cartBox = Hive.box<CartItem>('cart_box');
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('username') ?? '';
    });
  }

  double calculateTotal(List<CartItem> items) {
    double total = 0.0;
    for (var item in items) {
      double price = double.tryParse(item.price) ?? 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
           _phoneController.text.isNotEmpty &&
           _addressController.text.isNotEmpty &&
           selectedPaymentMethod.isNotEmpty &&
           isAddressConfirmed;
  }

  Future<String> performCheckout(List<String> keys, double total) async {
    final notifBox = Hive.box<NotificationItem>('notifications');
    final message =
        "You have successfully checked out with a total of ${total.toStringAsFixed(2)}"
        "\nDelivery Address: ${_addressController.text}"
        "\nRecipient: ${_nameController.text}"
        "\nPhone: ${_phoneController.text}";

    notifBox.add(
      NotificationItem(
        content: message,
        timestamp: DateTime.now(),
        transactions: selectedPaymentMethod,
      ),
    );

    for (var key in keys) {
      cartBox.delete(key);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment Successful! Check notification for payment recap.'),
          backgroundColor: Colors.green.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    }

    return message;
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.9), accentPink.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPurple, secondaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryPurple, secondaryBlue],
                  ).createShader(bounds),
                  child: const Text(
                    'Delivery Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter recipient\'s full name',
                prefixIcon: Icon(Icons.person, color: primaryPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter recipient\'s name';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            
            // Phone Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone, color: primaryPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            
            // Address Field
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                hintText: 'Enter complete delivery address',
                prefixIcon: Icon(Icons.location_on, color: primaryPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter delivery address';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                softWhite,
                accentPink.withOpacity(0.3),
                secondaryBlue.withOpacity(0.4),
                primaryPurple.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    final cartKeys = cartBox.keys
        .where((key) => key.toString().startsWith(currentUser))
        .toList();
    final userCartItems = cartKeys
        .map((key) => MapEntry(key.toString(), cartBox.get(key)!))
        .toList();

    if (userCartItems.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                softWhite,
                accentPink.withOpacity(0.3),
                secondaryBlue.withOpacity(0.4),
                primaryPurple.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: const Center(
            child: Text(
              'No item in cart.',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ),
      );
    }

    final items = userCartItems.map((e) => e.value).toList();
    final total = calculateTotal(items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPurple, secondaryBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              softWhite,
              accentPink.withOpacity(0.3),
              secondaryBlue.withOpacity(0.4),
              primaryPurple.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receipt Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.9), accentPink.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryPurple, secondaryBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryPurple, secondaryBlue],
                        ).createShader(bounds),
                        child: const Text(
                          'Receipt',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Cart Items
                ...userCartItems.map((entry) {
                  final item = entry.value;
                  final price = double.tryParse(item.price) ?? 0.0;
                  final subtotal = price * item.quantity;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          accentPink.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: primaryPurple,
                        ),
                      ),
                      subtitle: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [secondaryBlue.withOpacity(0.1), accentPink.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${price.toStringAsFixed(2)} × ${item.quantity} = ${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Total
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        accentPink.withOpacity(0.2),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryPurple, secondaryBlue],
                        ).createShader(bounds),
                        child: const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryPurple, secondaryBlue],
                        ).createShader(bounds),
                        child: Text(
                          total.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery Information Form
                _buildAddressForm(),

                const SizedBox(height: 20),

                // Payment Method
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.9), accentPink.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryPurple, secondaryBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.payment,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [primaryPurple, secondaryBlue],
                            ).createShader(bounds),
                            child: const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [secondaryBlue.withOpacity(0.1), accentPink.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryPurple.withOpacity(0.3)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPaymentMethod.isEmpty
                                  ? null
                                  : selectedPaymentMethod,
                              hint: const Text('Choose Payment Method'),
                              isExpanded: true,
                              items: paymentMethods.map((method) {
                                return DropdownMenuItem<String>(
                                  value: method['name'],
                                  child: Row(
                                    children: [
                                      Icon(
                                        method['icon'],
                                        color: primaryPurple,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(method['name']),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value ?? '';
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Address Confirmation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.9), accentPink.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isAddressConfirmed,
                        onChanged: (value) {
                          setState(() {
                            isAddressConfirmed = value ?? false;
                          });
                        },
                        activeColor: primaryPurple,
                      ),
                      const Expanded(
                        child: Text(
                          'I have made sure the delivery information is correct',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Checkout Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: !_isFormValid()
                        ? LinearGradient(
                            colors: [Colors.grey.shade300, Colors.grey.shade400],
                          )
                        : LinearGradient(
                            colors: [primaryPurple, secondaryBlue],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: !_isFormValid()
                        ? []
                        : [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: !_isFormValid()
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final checkoutMessage = await performCheckout(
                                cartKeys.map((e) => e.toString()).toList(),
                                total,
                              );
                              await showNotification(
                                title: 'Checkout Successful',
                                body: checkoutMessage,
                              );
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }
}