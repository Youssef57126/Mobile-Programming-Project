import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDrawer extends StatefulWidget {
  MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int orderCount = 0;
  DateTime? createdAt;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .get();

      final count = ordersSnapshot.size;
      final userDoc = await FirebaseAuth.instance.currentUser
          ?.getIdTokenResult();
      final creationTime = user.metadata?.creationTime;

      setState(() {
        orderCount = count;
        createdAt = creationTime;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAccountInfoDialog() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Guest';
    final createdDate = createdAt != null
        ? DateFormat('MMM dd, yyyy').format(createdAt!)
        : 'Unknown';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            SizedBox(height: 8),
            Text('Member since: $createdDate'),
            SizedBox(height: 8),
            Text('Total Orders: $orderCount'),
          ],
        ),
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
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Guest';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isLoading
                            ? Text('Loading...', style: TextStyle(fontSize: 12))
                            : Text(
                                '$orderCount Orders',
                                style: TextStyle(fontSize: 12),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Account Information'),
            onTap: _showAccountInfoDialog,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
