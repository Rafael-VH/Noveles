import 'package:flutter/material.dart';

import 'package:noveles/features/main/data/local/models/model.dart';

import 'package:noveles/features/main/presentation/views/detail/widgets/card_info_v1_detail.dart';

import 'package:noveles/features/main/presentation/widgets/widgets.dart';

class DetailView extends StatefulWidget {
  const DetailView({
    super.key,
    required this.books,
  });

  final BookLocalModel books;

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

            //
            titleWidget(
              text: 'Descripción',
              clContent: Theme.of(context).colorScheme.surface,
              clText: Colors.white,
            ),

            //
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.books.description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6.0),
              child: cardInfoV1Detail(
                context: context,
                title1: "Publicado",
                text1: widget.books.release,
                title2: "Tipo de Novela",
                text2: widget.books.type,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6.0),
              child: cardInfoV1Detail(
                context: context,
                title1: "País",
                text1: widget.books.country,
                title2: "Estado",
                text2: widget.books.state,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(6.0),
              child: cardInfoV1Detail(
                context: context,
                title1: "Tomos",
                text1: widget.books.took,
                title2: "Capítulos",
                text2: widget.books.chapter,
              ),
            ),

            //
            titleWidget(
              text: 'Generos',
              clContent: Theme.of(context).colorScheme.surface,
              clText: Colors.white,
            ),

            //
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
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
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
