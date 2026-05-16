import 'package:flutter/material.dart';

class SubTitleWidget extends StatelessWidget {
  const SubTitleWidget({
    super.key,
    required this.text,
    required this.clText,
  });

  final String text;
  final Color clText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22.0),
      child: Text(
        text,
        style: TextStyle(
          color: clText,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
