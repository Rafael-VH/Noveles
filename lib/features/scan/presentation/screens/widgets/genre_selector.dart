import 'package:flutter/material.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

class GenreSelector extends StatelessWidget {
  final List<GenreEntity> genres;
  final Set<int> selectedIds;
  final void Function(int id, bool selected) onToggle;

  const GenreSelector({
    super.key,
    required this.genres,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state
    if (genres.isEmpty) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cargando géneros...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: genres
          .map(
            (genre) => FilterChip(
              label: Text(genre.name),
              selected: selectedIds.contains(genre.id),
              onSelected: (selected) => onToggle(genre.id, selected),
              visualDensity: VisualDensity.compact,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            ),
          )
          .toList(),
    );
  }
}
