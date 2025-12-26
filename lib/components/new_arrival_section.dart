import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'product_card.dart';

class NewArrivalSection extends StatefulWidget {
  final String selectedCategory;
  final String searchQuery;

  NewArrivalSection({
    super.key,
    required this.selectedCategory,
    required this.searchQuery,
  });

  @override
  State<NewArrivalSection> createState() => _NewArrivalSectionState();
}

class _NewArrivalSectionState extends State<NewArrivalSection> {
  late Future<List<Map<String, dynamic>>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = _fetchBalancedProducts();
  }

  Future<List<Map<String, dynamic>>> _fetchBalancedProducts() async {
    int minPerCategory = 4;
    int totalTarget = 20;
    List<String> categories = ['Clothes', 'Electronics', 'Furniture', 'Shoes'];

    final Map<String, List<Map<String, dynamic>>> categoryProducts = {
      'Clothes': [],
      'Electronics': [],
      'Furniture': [],
      'Shoes': [],
    };

    final random = Random();
    final usedIds = <int>{};

    for (String category in categories) {
      int attempts = 0;
      while (categoryProducts[category]!.length < minPerCategory &&
          attempts < 50) {
        final id = random.nextInt(106) + 1;
        if (usedIds.contains(id)) {
          attempts++;
          continue;
        }

        try {
          final response = await http
              .get(Uri.parse('http://10.0.2.2:5000/api/v1/products/$id'))
              .timeout(Duration(seconds: 6));

          if (response.statusCode == 200) {
            final product = json.decode(response.body);
            if (product is Map<String, dynamic> &&
                product['category'] == category) {
              categoryProducts[category]!.add(product);
              usedIds.add(id);
            }
          }
        } catch (e) {}
        attempts++;
      }
    }

    List<Map<String, dynamic>> selectedProducts = [];

    for (var products in categoryProducts.values) {
      selectedProducts.addAll(products);
    }

    while (selectedProducts.length < totalTarget) {
      final id = random.nextInt(106) + 1;
      if (usedIds.contains(id)) continue;

      try {
        final response = await http
            .get(Uri.parse('http://10.0.2.2:5000/api/v1/products/$id'))
            .timeout(Duration(seconds: 6));

        if (response.statusCode == 200) {
          final product = json.decode(response.body);
          if (product is Map<String, dynamic>) {
            selectedProducts.add(product);
            usedIds.add(id);
          }
        }
      } catch (e) {}
    }

    selectedProducts.shuffle(random);

    return selectedProducts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load products',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => futureProducts = _fetchBalancedProducts(),
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];

        var filteredProducts = products;

        if (widget.selectedCategory != 'All') {
          filteredProducts = filteredProducts
              .where((p) => p['category'] == widget.selectedCategory)
              .toList();
        }

        if (widget.searchQuery.isNotEmpty) {
          final query = widget.searchQuery.toLowerCase().trim();
          filteredProducts = filteredProducts.where((product) {
            final title = (product['title'] as String?)?.toLowerCase() ?? '';
            final description =
                (product['description'] as String?)?.toLowerCase() ?? '';
            return title.contains(query) || description.contains(query);
          }).toList();
        }

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.selectedCategory == 'All'
                        ? 'New Arrival'
                        : widget.selectedCategory,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Text('View All', style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16),
              filteredProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(60),
                        child: Text(
                          'No products found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          id: product['id'] as int,
                          imageUrl: product['imageUrl'] as String,
                          title: product['title'] as String,
                          price: (product['price'] as num).toDouble(),
                          category: product['category'] as String,
                          description:
                              product['description'] as String? ??
                              'No description',
                        );
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}
