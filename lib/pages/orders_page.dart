import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/top_bar.dart';
import '../components/greeting_section.dart';
import '../utils/cart_and_favorites.dart';

class OrdersPage extends StatefulWidget {
  OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<AppOrder> orderHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .orderBy('date', descending: true)
          .get();

      final List<AppOrder> loadedOrders = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        loadedOrders.add(
          AppOrder(
            items: (data['items'] as List).map((itemData) {
              return ProductItem(
                id: itemData['id'],
                title: itemData['title'],
                price: itemData['price'],
                quantity: itemData['quantity'],
                imageUrl: itemData['imageUrl'],
                category: itemData['category'] ?? '',
              );
            }).toList(),
            total: (data['total'] as num).toDouble(),
            address: data['address'],
            paymentMethod: data['paymentMethod'],
            date: (data['date'] as Timestamp).toDate(),
          ),
        );
      }

      setState(() {
        orderHistory = loadedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
    }
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
                    'Please login to view orders',
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
        child: Column(
          children: [
            TopBar(),
            GreetingSection(),
            SizedBox(height: 20),
            Expanded(
              child: orderHistory.isEmpty
                  ? Center(
                      child: Text(
                        'No orders yet 📦',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: orderHistory.length,
                      itemBuilder: (context, index) {
                        final order = orderHistory[index];
                        final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Order #${orderHistory.length - index}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              dateFormat.format(order.date),
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF9100),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Items:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ...order.items.map(
                                      (item) => Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item.quantity} × ${item.title}',
                                                style: TextStyle(fontSize: 14),
                                                softWrap: true,
                                              ),
                                            ),
                                            Text(
                                              '\$${(item.price * item.quantity).toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(height: 30),
                                    Text('Delivery Address: ${order.address}'),
                                    Text(
                                      'Payment Method: ${order.paymentMethod}',
                                    ),
                                    SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'Total Paid: \$${order.total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
