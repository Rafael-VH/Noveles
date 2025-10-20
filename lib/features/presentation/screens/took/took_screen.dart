import 'package:flutter/material.dart';
import 'package:noveles/features/data/local/models/model.dart';
import 'package:noveles/features/presentation/pages/pages.dart';

class TookScreen extends StatefulWidget {
  const TookScreen({
    super.key,
    required this.tooks,
  });

  final TookLocalModel tooks;

  @override
  State<TookScreen> createState() => _TookScreenState();
}

class _TookScreenState extends State<TookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TookPage(
        tooks: widget.tooks,
      ),
    );
  }
}
