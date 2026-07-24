import 'package:flutter/material.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_metadata_grid.dart';

class InfoPair {
  final String title;
  final String value;

  const InfoPair({
    required this.title,
    required this.value,
  });
}

class CardInfoDetail extends StatelessWidget {
  final List<InfoPair> pairs;

  const CardInfoDetail({
    super.key,
    required this.pairs,
  });

  @override
  Widget build(BuildContext context) {
    return BookMetadataGrid(
      items: pairs
          .map((p) => MetadataItemData(
                title: p.title,
                value: p.value,
                icon: Icons.info_outline_rounded,
              ))
          .toList(),
    );
  }
}
