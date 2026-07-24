import 'package:flutter/material.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class BookQuickStatsBar extends StatelessWidget {
  final BookWithRelations book;

  const BookQuickStatsBar({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(isDark ? 30 : 45),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(isDark ? 30 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.auto_stories_rounded,
            label: 'Tomos',
            value: book.tookCount.toString(),
            color: colorScheme.primary,
          ),
          _VerticalDivider(colorScheme: colorScheme, isDark: isDark),
          _StatItem(
            icon: Icons.menu_book_rounded,
            label: 'Capítulos',
            value: book.chapterCount.toString(),
            color: colorScheme.tertiary,
          ),
          _VerticalDivider(colorScheme: colorScheme, isDark: isDark),
          _StatItem(
            icon: Icons.flag_rounded,
            label: 'Origen',
            value: book.country.isNotEmpty ? book.country : '—',
            color: colorScheme.secondary,
          ),
          _VerticalDivider(colorScheme: colorScheme, isDark: isDark),
          _StatItem(
            icon: Icons.info_outline_rounded,
            label: 'Estado',
            value: book.state.isNotEmpty ? book.state : '—',
            color: colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;

  const _VerticalDivider({
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: colorScheme.outlineVariant.withAlpha(isDark ? 40 : 50),
    );
  }
}
