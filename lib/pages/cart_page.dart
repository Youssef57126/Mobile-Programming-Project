import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../components/top_bar.dart';
import '../components/greeting_section.dart';
import '../utils/cart_and_favorites.dart';

class CartPage extends StatefulWidget {
  CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';

  final double taxRate = 0.10;
  final double deliveryFee = 10.0;

  List<ProductItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      final List<ProductItem> loadedItems = [];
      for (var doc in snapshot.docs) {
        final productId = int.parse(doc.id);
        final quantity = doc.data()['quantity'] as int;
        final productData = await _fetchProductById(productId);
        if (productData != null) {
          loadedItems.add(
            ProductItem(
              id: productData['id'],
              title: productData['title'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],
              category: productData['category'],
              description: productData['description'],
              quantity: quantity,
            ),
          );
        }
      }
      setState(() {
        cartItems = loadedItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading cart: $e')));
    }
  }

  Future<Map<String, dynamic>?> _fetchProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/v1/products/$id'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching product $id: $e');
    }
    return null;
  }

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax + deliveryFee;

  Future<void> _updateQuantity(ProductItem item, int newQuantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(item.id.toString());

    if (newQuantity <= 0) {
      await cartRef.delete();
      setState(() => cartItems.remove(item));
    } else {
      await cartRef.update({'quantity': newQuantity});
      setState(() => item.quantity = newQuantity);
    }
  }

  Future<void> _confirmOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please login to place order")));
      return;
    }
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Your cart is empty!')));
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter your address')));
      return;
    }

    if (_paymentMethod == 'Pay with Visa') {
      if (_cardNumberController.text.trim().isEmpty ||
          _expiryController.text.trim().isEmpty ||
          _cvvController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all Visa card details')),
        );
        return;
      }
    }

    final orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc();

    await orderRef.set({
      'total': total,
      'address': _addressController.text.trim(),
      'paymentMethod': _paymentMethod,
      'date': FieldValue.serverTimestamp(),
      'items': cartItems
          .map(
            (i) => {
              'id': i.id,
              'title': i.title,
              'price': i.price,
              'quantity': i.quantity,
              'imageUrl': i.imageUrl,
            },
          )
          .toList(),
    });

    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      cartItems.clear();
      _addressController.clear();
      _cardNumberController.clear();
      _expiryController.clear();
      _cvvController.clear();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Confirmed!'),
        content: Text('Your order has been placed!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TopBar(),
              GreetingSection(),
              SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Text(
                    'Please login to view cart',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TopBar(),
              GreetingSection(),
              SizedBox(height: 20),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: cartItems.isEmpty
            ? Column(
                children: [
                  TopBar(),
                  GreetingSection(),
                  SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Your cart is empty',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: TopBar()),
                  SliverToBoxAdapter(child: GreetingSection()),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${item.price.toStringAsFixed(0)} each',
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed: () => _updateQuantity(
                                              item,
                                              item.quantity - 1,
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            onPressed: () => _updateQuantity(
                                              item,
                                              item.quantity + 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '\$${(item.price * item.quantity).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF9100),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _updateQuantity(item, 0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: cartItems.length),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              hintText: 'Enter your full address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          RadioListTile<String>(
                            title: Text('Cash on Delivery'),
                            value: 'Cash on Delivery',
                            groupValue: _paymentMethod,
                            onChanged: (val) =>
                                setState(() => _paymentMethod = val!),
                          ),
                          RadioListTile<String>(
                            title: Text('Pay with Visa'),
                            value: 'Pay with Visa',
                            groupValue: _paymentMethod,
                            onChanged: (val) =>
                                setState(() => _paymentMethod = val!),
                          ),

                          if (_paymentMethod == 'Pay with Visa') ...[
                            SizedBox(height: 20),
                            Text(
                              'Visa Card Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.credit_card),
                                labelText: 'Card Number',
                                hintText: '1234 5678 9012 3456',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _expiryController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Expiry Date',
                                      hintText: 'MM/YY',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _cvvController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'CVV',
                                      hintText: '123',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal'),
                              Text('\$${subtotal.toStringAsFixed(0)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tax (${(taxRate * 100).toStringAsFixed(0)}%)',
                              ),
                              Text('\$${tax.toStringAsFixed(0)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Fee'),
                              Text('\$${deliveryFee.toStringAsFixed(0)}'),
                            ],
                          ),
                          Divider(thickness: 1.5, height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9100),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _confirmOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF9100),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Confirm Order',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
      ),
    );
  }
}
