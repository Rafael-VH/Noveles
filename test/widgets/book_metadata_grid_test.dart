import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_metadata_grid.dart';

void main() {
  testWidgets('BookMetadataGrid renders items correctly', (tester) async {
    const items = [
      MetadataItemData(
        title: 'Publicado',
        value: '2024',
        icon: Icons.calendar_today_rounded,
      ),
      MetadataItemData(
        title: 'Tipo Novela',
        value: 'Web Novel',
        icon: Icons.bookmark_border_rounded,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BookMetadataGrid(items: items),
        ),
      ),
    );

    expect(find.text('PUBLICADO'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('TIPO NOVELA'), findsOneWidget);
    expect(find.text('Web Novel'), findsOneWidget);
  });
}
