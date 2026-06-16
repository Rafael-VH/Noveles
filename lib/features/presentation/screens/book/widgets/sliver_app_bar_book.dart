import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/books/domain/book_entity.dart';

class SliverAppBarBook extends StatelessWidget {
  const SliverAppBarBook({
    super.key,
    required this.books,
  });

  final BookEntity books;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: const Text('Details'),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      expandedHeight: 360.0,
      flexibleSpace: SizedBox(
        height: 360.0,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: getIt<CoverUrlService>()(books.cover),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface.withAlpha(10),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.5),
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.7),
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 65.0,
              left: 16.0,
              right: 16.0,
              bottom: 0.0,
              child: SizedBox(
                child: Column(
                  children: [
                    Expanded(
                      flex: 10,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: getIt<CoverUrlService>()(books.cover),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.book, size: 48),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          books.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        books.author,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
