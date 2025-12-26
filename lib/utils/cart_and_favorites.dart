import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductItem {
  final int id;
  final String imageUrl;
  final String title;
  final double price;
  final String category;
  final String? description;
  int quantity = 1;

  ProductItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.category,
    this.description,
    this.quantity = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}

class AppOrder {
  final List<ProductItem> items;
  final double total;
  final String address;
  final String paymentMethod;
  final DateTime date;

  AppOrder({
    required this.items,
    required this.total,
    required this.address,
    required this.paymentMethod,
    required this.date,
  });
}

List<ProductItem> favoriteProducts = [];
List<ProductItem> cartProducts = [];
List<AppOrder> orderHistory = [];

String? get currentUserUid => FirebaseAuth.instance.currentUser?.uid;
