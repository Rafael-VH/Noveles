import 'package:flutter/material.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';

class GenreChipStyled extends StatelessWidget {
  final GenreEntity genre;
  final VoidCallback onTap;
  final IconData? icon;

  const GenreChipStyled({
    super.key,
    required this.genre,
    required this.onTap,
    this.icon,
  });

  IconData _iconForGenre(String name) {
    switch (name.toLowerCase()) {
      case 'aventura':
        return Icons.explore;
      case 'romance':
        return Icons.favorite;
      case 'fantasía':
      case 'fantasia':
        return Icons.auto_stories;
      case 'ciencia ficción':
      case 'ciencia ficcion':
        return Icons.rocket_launch;
      case 'terror':
        return Icons.dangerous;
      case 'misterio':
        return Icons.search;
      case 'drama':
        return Icons.theater_comedy;
      case 'comedia':
        return Icons.sentiment_satisfied;
      case 'acción':
      case 'accion':
        return Icons.flash_on;
      case 'histórico':
      case 'historico':
        return Icons.history;
      case 'suspenso':
        return Icons.psychology;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIcon = icon ?? _iconForGenre(genre.name);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(effectiveIcon, size: 18),
            const SizedBox(width: 6),
            Text(genre.name),
          ],
        ),
      ),
    );
  }
}
