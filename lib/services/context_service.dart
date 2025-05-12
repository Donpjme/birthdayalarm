import 'package:flutter/material.dart';

class ContextService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get currentContext => navigatorKey.currentState!.context;

  static void showLoading() {
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideLoading() {
    if (Navigator.canPop(currentContext)) {
      Navigator.pop(currentContext);
    }
  }

  static void showMessage(String message) {
    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}