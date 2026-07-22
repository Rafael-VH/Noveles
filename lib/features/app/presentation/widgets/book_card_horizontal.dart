import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class BookCardHorizontal extends StatelessWidget {
  final BookWithRelations book;
  final VoidCallback onTap;

  const BookCardHorizontal({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 120,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: getIt<CoverUrlService>()(book.cover),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        book.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.menu_book, size: 16),
                          const SizedBox(width: 4),
                          Text('${book.tookCount} tomos'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
