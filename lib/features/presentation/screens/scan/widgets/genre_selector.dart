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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Géneros',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Loading state
        if (genres.isEmpty)
          Text(
            'Cargando géneros...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )

        // Genre chips
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: genres
                .map(
                  (genre) => FilterChip(
                    label: Text(genre.name),
                    selected: selectedIds.contains(genre.id),
                    onSelected: (selected) => onToggle(genre.id, selected),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
