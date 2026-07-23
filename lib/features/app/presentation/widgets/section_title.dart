import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool showAccent;

  const SectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    this.padding,
    this.showAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    final trailingWidget = trailing;

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showAccent)
            Container(
              height: 26.0,
              width: 6.0,
              margin: const EdgeInsets.only(right: 4.0),
              color: Theme.of(context).colorScheme.primary,
            ),
          if (iconData != null) ...[
            Icon(iconData,
                size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }
}
