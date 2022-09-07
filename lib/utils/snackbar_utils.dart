import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showErrorSnackBar(
    BuildContext context, {
    required String text,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isError ? Colors.red : Colors.blue,
        ),
      ),
      duration: const Duration(
        seconds: 1,
      ),
    ));
  }
}
