import 'package:flutter/material.dart';

Widget subTitleWidget({
  required String text,
  required Color clText,
}) {
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
