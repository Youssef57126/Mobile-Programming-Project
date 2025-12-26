import 'package:flutter/material.dart';

class SquareTitle extends StatelessWidget {
  final String imagPath;
  final double? width;
  final double? height;
  Function()? onTap;
  SquareTitle({
    super.key,
    required this.imagPath,
    this.height,
    this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Image.asset(imagPath, width: width, height: height),
      ),
    );
  }
}
