import 'package:flutter/material.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/presentation/views/detail/widgets/card_info_detail.dart';
import 'package:noveles/core/presentation/widgets/title_widget.dart';
import 'package:noveles/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailView extends StatefulWidget {
  const DetailView({
    super.key,
    required this.books,
  });

  final BookWithRelations books;

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 22.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TitleWidget(
                  text: 'Descripción',
                  clContent: Theme.of(context).colorScheme.primary,
                  clText: Theme.of(context).colorScheme.onSurface,
                ),
                FavoriteButton(
                  bookId: widget.books.id,
                  initialIsFavorite: widget.books.isFavorite,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.books.description,
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
                text1: widget.books.release,
                title2: "Tipo de Novela",
                text2: widget.books.type,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: CardInfoDetail(
                title1: "País",
                text1: widget.books.country,
                title2: "Estado",
                text2: widget.books.state,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: CardInfoDetail(
                title1: "Tomos",
                text1: widget.books.tookCount.toString(),
                title2: "Capítulos",
                text2: widget.books.chapterCount.toString(),
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
                children: widget.books.listGenre.map((item) {
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
            if (widget.books.source.isNotEmpty ||
                widget.books.link.isNotEmpty) ...[
              TitleWidget(
                text: 'Fuente',
                clContent: Theme.of(context).colorScheme.primary,
                clText: Theme.of(context).colorScheme.onSurface,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CardInfoDetail(
                  title1: "Fuente",
                  text1: widget.books.source.isNotEmpty
                      ? widget.books.source
                      : "N/A",
                  title2: "Enlace",
                  text2:
                      widget.books.link.isNotEmpty ? widget.books.link : "N/A",
                ),
              ),
              if (widget.books.link.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: InkWell(
                    onTap: () async {
                      final uri = Uri.parse(widget.books.link);
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
        ),
      ),
    );
  }
}
