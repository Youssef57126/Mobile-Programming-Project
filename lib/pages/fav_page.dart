import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/top_bar.dart';
import '../components/greeting_section.dart';
import '../components/product_card.dart';

class FavPage extends StatefulWidget {
  FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<Map<String, dynamic>> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final favSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final List<int> favoriteIds = favSnapshot.docs
          .map((doc) => int.parse(doc.id))
          .toList();

      if (favoriteIds.isEmpty) {
        setState(() {
          favoriteProducts = [];
          isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> loadedFavorites = [];

      for (int id in favoriteIds) {
        final product = await _fetchProductById(id);
        if (product != null) {
          loadedFavorites.add(product);
        }
      }

      setState(() {
        favoriteProducts = loadedFavorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading favorites: $e')));
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
                    'Please login to view favorites',
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
              child: favoriteProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No favorites yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: favoriteProducts.length,
                      itemBuilder: (context, index) {
                        final product = favoriteProducts[index];
                        return ProductCard(
                          id: product['id'],
                          imageUrl: product['imageUrl'],
                          title: product['title'],
                          price: product['price'],
                          category: product['category'],
                          description: product['description'],
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
