import 'package:flutter/material.dart';
import 'package:noveles/features/domain/entities/entities.dart';

class GenrePage extends StatefulWidget {
  const GenrePage({
    super.key,
    required this.books,
    required this.genre,
  });

  final List<BookEntity> books;
  final String genre;

  @override
  State<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text('Genero: ${widget.genre}'),
        ),
        widget.books.isEmpty
            ? const Center(child: Text('No books available for this genre'))
            : SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 0.65,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: widget.books.length,
                  (BuildContext context, int index) {
                    final book = widget.books[index];

                    return Card(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image(
                              fit: BoxFit.cover,
                              image: AssetImage(book.cover),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    Theme.of(context).colorScheme.surface,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 4.0,
                            right: 4.0,
                            bottom: 8.0,
                            child: Text(
                              book.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
