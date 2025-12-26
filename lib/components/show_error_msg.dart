import 'package:flutter/material.dart';

void sharedErrorMessage(BuildContext context, String msg) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          msg,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ],
      );
    },
  );
}
