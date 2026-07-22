import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class BookCardVertical extends StatelessWidget {
  final BookWithRelations book;
  final VoidCallback onTap;
  final double? width;

  const BookCardVertical({
    super.key,
    required this.book,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width ?? 140,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: getIt<CoverUrlService>()(book.cover),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
