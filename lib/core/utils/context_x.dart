import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../widgets/app_snackbar.dart';

extension ContextX on BuildContext {
  TextTheme get text => Theme.of(this).textTheme;

  void showSnack(String message) => AppSnackbar.info(this, message);

  void showSuccess(String message) => AppSnackbar.success(this, message);

  /// Accepts a message or any error object; unknown errors get a generic message.
  void showError(Object error) =>
      AppSnackbar.error(this, error is String ? error : errorMessage(error));
}
