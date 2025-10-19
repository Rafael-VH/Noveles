import 'package:flutter/material.dart';

Widget titleWidget({
  required String text,
  required Color clContent,
  required Color clText,
}) {
  return Container(
    height: 40.0,
    width: double.infinity,
    padding: const EdgeInsets.all(4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 26.0,
          width: 6.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          color: clContent,
        ),
        Text(
          text,
          style: TextStyle(
            color: clText,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ),
  );
}
