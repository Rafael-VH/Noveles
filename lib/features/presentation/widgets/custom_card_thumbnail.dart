import 'package:flutter/material.dart';

class CustomCardThumbnail extends StatelessWidget {
  const CustomCardThumbnail({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  final String description;
  final String imageAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(26.0),
        topRight: Radius.circular(26.0),
        bottomLeft: Radius.circular(26.0),
        bottomRight: Radius.circular(26.0),
      ),
      child: SizedBox(
        height: 240.0,
        width: size.width,
        child: Row(
          children: [
            Expanded(
              child: Container(
                foregroundDecoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color.fromARGB(255, 36, 36, 36),
                      Color.fromARGB(125, 36, 36, 36),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Image(
                  height: size.height,
                  width: size.width,
                  fit: BoxFit.cover,
                  image: AssetImage(
                    imageAsset,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
