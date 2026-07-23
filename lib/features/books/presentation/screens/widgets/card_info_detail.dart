import 'package:flutter/material.dart';

class InfoPair {
  final String title;
  final String value;

  const InfoPair({
    required this.title,
    required this.value,
  });
}

class CardInfoDetail extends StatelessWidget {
  final List<InfoPair> pairs;

  const CardInfoDetail({
    super.key,
    required this.pairs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < pairs.length; i++) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      pairs[i].title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      pairs[i].value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < pairs.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
