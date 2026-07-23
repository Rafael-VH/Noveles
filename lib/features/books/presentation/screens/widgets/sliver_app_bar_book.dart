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
    final theme = Theme.of(context);
    final expandedHeight =
        (MediaQuery.of(context).size.height * 0.48).clamp(280.0, 420.0);
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return SliverAppBar(
      title: Text(
        books.name,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      stretch: true,
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          children: [
            // Full-bleed cover image
            Positioned.fill(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: getIt<CoverUrlService>()(books.cover),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            // Blur overlay sigma 5
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: scaffoldBg.withAlpha(10),
                  ),
                ),
              ),
            ),
            // Gradient fading into scaffold background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scaffoldBg.withValues(alpha: 0.5),
                      scaffoldBg.withValues(alpha: 0.7),
                      scaffoldBg,
                    ],
                  ),
                ),
              ),
            ),
            // Thumbnail with AspectRatio + title + author
            Positioned(
              top: 65.0,
              left: 16.0,
              right: 16.0,
              bottom: 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: getIt<CoverUrlService>()(books.cover),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.book, size: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    books.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    books.author,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
