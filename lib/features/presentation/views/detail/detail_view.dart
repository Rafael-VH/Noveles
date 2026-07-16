import 'package:flutter/material.dart';
import 'package:noveles/features/books/domain/book_with_relations.dart';
import 'package:noveles/features/presentation/views/detail/widgets/card_info_detail.dart';
import 'package:noveles/features/presentation/widgets/widgets.dart';

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
        child: Column(
          children: [
            const SizedBox(height: 22.0),
            TitleWidget(
              text: 'Descripción',
              clContent: Theme.of(context).colorScheme.primary,
              clText: Theme.of(context).colorScheme.onSurface,
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
          ],
        ),
      ),
    );
  }
}
