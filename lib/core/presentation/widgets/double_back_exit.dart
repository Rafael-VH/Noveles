import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackExit extends StatefulWidget {
  final Widget child;

  const DoubleBackExit({super.key, required this.child});

  @override
  State<DoubleBackExit> createState() => _DoubleBackExitState();
}

class _DoubleBackExitState extends State<DoubleBackExit> {
  DateTime? _lastBackPress;

  void _onPopInvoked(bool didPop) {
    if (didPop) return;

    final now = DateTime.now();
    final isFirstPress =
        _lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2);

    if (isFirstPress) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presione de nuevo para salir'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPopInvoked(didPop),
      child: widget.child,
    );
  }
}
