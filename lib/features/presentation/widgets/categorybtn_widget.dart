import 'package:flutter/material.dart';

class CategoryBTNWidget extends StatelessWidget {
  const CategoryBTNWidget({
    super.key,
    this.buttonClr = Colors.grey,
    required this.label,
    this.height = 60.0,
    this.size = 16.0,
    this.onPress,
  });

  final Color buttonClr;
  final String label;
  final double height;
  final double size;
  final void Function()? onPress;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPress,
      child: Container(
        height: height,
        width: MediaQuery.of(context).size.width * 0.355,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border:
              Border.all(width: 1, color: buttonClr, style: BorderStyle.solid),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size,
              color: buttonClr,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
