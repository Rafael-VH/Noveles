import 'package:flutter/material.dart';
import 'package:noveles/features/books/favorites/presentation/widgets/favorite_button.dart';

class BookActionBar extends StatelessWidget {
  final int bookId;
  final bool initialIsFavorite;
  final VoidCallback onReadTap;

  const BookActionBar({
    super.key,
    required this.bookId,
    required this.initialIsFavorite,
    required this.onReadTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onReadTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 2,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                'Comenzar Lectura',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(50),
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: FavoriteButton(
              bookId: bookId,
              initialIsFavorite: initialIsFavorite,
            ),
          ),
        ],
      ),
    );
  }
}
