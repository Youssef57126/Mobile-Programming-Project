import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatefulWidget {
  final int id;
  final String imageUrl;
  final String title;
  final double price;
  final String category;
  final String description;

  ProductDetailPage({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.id.toString())
        .get();

    if (mounted) {
      setState(() {
        isFavorited = doc.exists;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please login to save favorites")));
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.id.toString());

    if (isFavorited) {
      await favRef.delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Removed from favorites')));
    } else {
      await favRef.set({'addedAt': FieldValue.serverTimestamp()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title} added to favorites ❤️')),
      );
    }

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please login to add to cart")));
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(widget.id.toString());

    final doc = await cartRef.get();

    if (doc.exists) {
      final currentQty = doc.data()?['quantity'] as int? ?? 0;
      await cartRef.update({'quantity': currentQty + quantity});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $quantity more (total: ${currentQty + quantity})',
          ),
        ),
      );
    } else {
      await cartRef.set({
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $quantity × ${widget.title} to cart 🛒')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(widget.imageUrl, height: 400, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${widget.price}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9100),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Quantity:', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(
                          () => quantity = quantity > 1 ? quantity - 1 : 1,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => quantity++),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF9100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Add $quantity to Cart',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
