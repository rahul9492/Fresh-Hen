import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;

  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
