import 'package:flutter/material.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/presentation/views/detail/widgets/card_info_detail.dart';
import 'package:noveles/core/presentation/widgets/title_widget.dart';
import 'package:noveles/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailContent extends StatelessWidget {
  final BookWithRelations books;

  const BookDetailContent({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 22.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: TitleWidget(
                text: 'Descripción',
                clContent: Theme.of(context).colorScheme.primary,
                clText: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            FavoriteButton(
              bookId: books.id,
              initialIsFavorite: books.isFavorite,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            books.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: CardInfoDetail(
            title1: "Publicado",
            text1: books.release,
            title2: "Tipo de Novela",
            text2: books.type,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: CardInfoDetail(
            title1: "País",
            text1: books.country,
            title2: "Estado",
            text2: books.state,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: CardInfoDetail(
            title1: "Tomos",
            text1: books.tookCount.toString(),
            title2: "Capítulos",
            text2: books.chapterCount.toString(),
          ),
        ),
        TitleWidget(
          text: 'Generos',
          clContent: Theme.of(context).colorScheme.primary,
          clText: Theme.of(context).colorScheme.onSurface,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: books.listGenre.map((item) {
              return InkWell(
                onTap: () {},
                child: Chip(
                  elevation: 8.0,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  label: Text(
                    item.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (books.source.isNotEmpty || books.link.isNotEmpty) ...[
          TitleWidget(
            text: 'Fuente',
            clContent: Theme.of(context).colorScheme.primary,
            clText: Theme.of(context).colorScheme.onSurface,
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: CardInfoDetail(
              title1: "Fuente",
              text1: books.source.isNotEmpty ? books.source : "N/A",
              title2: "Enlace",
              text2: books.link.isNotEmpty ? books.link : "N/A",
            ),
          ),
          if (books.link.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                    color: Theme.of(context).colorScheme.primary,
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
