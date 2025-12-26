import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Glamora',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(
            'Discover the Glam in You',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
