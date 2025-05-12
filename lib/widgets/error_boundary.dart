import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error)? errorBuilder;

  const ErrorBoundary({
    super.key,  // Changed to use super parameter
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Something went wrong\n${_error.toString()}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
    }

    return widget.child;
  }

  @override
  void dispose() {
    // Reset error handler
    FlutterError.onError = null;
    super.dispose();
  }
}

class YourWidget extends StatelessWidget {
  const YourWidget({super.key});  // Added const constructor with super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Widget'),
      ),
      body: const Center(
        child: Text('This is your widget'),
      ),
    );
  }
}

class CustomErrorWidget extends StatelessWidget {
  final Object error;

  const CustomErrorWidget({
    super.key,  // Changed to use super parameter
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Custom error: ${error.toString()}',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}

void main() {
  runApp(
    ErrorBoundary(
      child: YourWidget(),
      errorBuilder: (error) => CustomErrorWidget(error: error),
    ),
  );
}