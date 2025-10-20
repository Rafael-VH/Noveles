import 'package:flutter/material.dart';
import 'package:noveles/features/data/local/models/model.dart';

class CustomCardNormal extends StatelessWidget {
  const CustomCardNormal({
    super.key,
    required this.novelModel,
  });

  final BookLocalModel novelModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260.0,
          width: 140.0,
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                novelModel.cover,
              ),
            ),
          ),
        ),
        Positioned(
          left: 15,
          right: 15,
          bottom: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novelModel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      novelModel.release,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
