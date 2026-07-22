import 'package:flutter/material.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_horizontal.dart';
import 'package:noveles/features/app/presentation/widgets/section_header.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class SectionPopulares extends StatelessWidget {
  final List<BookWithRelations> books;
  final void Function(BookWithRelations) onBookTap;

  const SectionPopulares({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SectionHeader(title: 'Populares', icon: Icons.trending_up),
        ...books.map(
          (book) => BookCardHorizontal(
            book: book,
            onTap: () => onBookTap(book),
          ),
        ),
      ],
    );
  }
}
