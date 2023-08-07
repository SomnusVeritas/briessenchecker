import 'package:flutter/material.dart';

class Messenger {
  static void showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          error,
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
      ),
    );
  }
}
