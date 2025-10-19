import 'package:flutter/material.dart';
import 'package:noveles/features/main/presentation/widgets/widgets.dart';

Widget infoTextWidget({
  required Size size,
  required Color clrContainer,
  required Color clrContent,
  required String title1,
  required String text1,
  required String title2,
  required String text2,
}) {
  return Container(
    width: size.width,
    height: 70.0,
    margin: const EdgeInsets.symmetric(horizontal: 10.0),
    padding: const EdgeInsets.symmetric(horizontal: 6.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      color: clrContainer,
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            children: [
              titleWidget(
                text: title1,
                clContent: clrContent,
                clText: Colors.white,
              ),
              subTitleWidget(
                text: text1,
                clText: Colors.grey,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              titleWidget(
                text: title2,
                clContent: clrContent,
                clText: Colors.white,
              ),
              subTitleWidget(
                text: text2,
                clText: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
