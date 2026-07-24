import 'package:flutter/material.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/presentation/screens/widgets/card_info_detail.dart';
import 'package:noveles/features/app/presentation/widgets/section_title.dart';
import 'package:noveles/features/app/presentation/widgets/genre_chip_styled.dart';
import 'package:noveles/features/books/favorites/presentation/widgets/favorite_button.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailContent extends StatelessWidget {
  final BookWithRelations books;

  const BookDetailContent({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 22.0),
        // ── Description section ───────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: SectionTitle(
                title: 'Descripción',
                showAccent: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: FavoriteButton(
                bookId: books.id,
                initialIsFavorite: books.isFavorite,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            books.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // ── Info cards (merged) ────────────────────────────────
        const SectionTitle(
          title: 'Detalles',
          showAccent: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: CardInfoDetail(
            pairs: [
              InfoPair(title: 'Publicado', value: books.release),
              InfoPair(title: 'Tipo de Novela', value: books.type),
              InfoPair(title: 'País', value: books.country),
              InfoPair(title: 'Estado', value: books.state),
              InfoPair(title: 'Tomos', value: books.tookCount.toString()),
              InfoPair(title: 'Capítulos', value: books.chapterCount.toString()),
            ],
          ),
        ),
        // ── Genres section ─────────────────────────────────────
        const SizedBox(height: 16),
        SectionTitle(
          title: 'Generos',
          showAccent: true,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: books.listGenre.map((item) {
              return GenreChipStyled(
                genre: item,
                onTap: () {},
              );
            }).toList(),
          ),
        ),
        // ── Source section (conditional) ───────────────────────
        if (books.source.isNotEmpty || books.link.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionTitle(
            title: 'Fuente',
            showAccent: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
            child: CardInfoDetail(
              pairs: [
                InfoPair(
                  title: 'Fuente',
                  value: books.source.isNotEmpty ? books.source : 'N/A',
                ),
                InfoPair(
                  title: 'Enlace',
                  value: books.link.isNotEmpty ? books.link : 'N/A',
                ),
              ],
            ),
          ),
          if (books.link.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () async {
                  final uri = Uri.parse(books.link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Text(
                  'Abrir enlace',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
