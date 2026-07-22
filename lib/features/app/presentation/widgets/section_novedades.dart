import 'package:flutter/material.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_vertical.dart';
import 'package:noveles/features/app/presentation/widgets/section_header.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class SectionNovedades extends StatelessWidget {
  final List<BookWithRelations> books;
  final void Function(BookWithRelations) onBookTap;

  const SectionNovedades({
    super.key,
    required this.books,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SectionHeader(title: 'Novedades', icon: Icons.new_releases),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BookCardVertical(
                  book: book,
                  onTap: () => onBookTap(book),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
