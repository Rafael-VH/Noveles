import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';

class CoverPicker extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const CoverPicker({
    super.key,
    required this.controller,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCover = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Tap-to-select area
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasCover
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        getIt<CoverUrlService>()(controller.text),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PlaceholderContent(
                          icon: Icons.broken_image,
                          text: 'Error al cargar imagen',
                          theme: theme,
                        ),
                      ),
                      // Gradient overlay
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(140),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Tocá para cambiar',
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : _PlaceholderContent(
                    icon: Icons.add_photo_alternate_outlined,
                    text: 'Tocá para agregar portada',
                    theme: theme,
                  ),
          ),
        ),
        // Action row
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.image, size: 18),
              label: Text(hasCover ? 'Cambiar imagen' : 'Seleccionar imagen'),
            ),
            if (hasCover)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Quitar'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
          ],
        ),
        // URL text
        if (hasCover)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              controller.text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const _PlaceholderContent({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant.withAlpha(120)),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
