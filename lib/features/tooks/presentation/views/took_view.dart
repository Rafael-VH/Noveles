import 'package:flutter/material.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

class TookView extends StatefulWidget {
  final List<TookEntity> tooks;
  final void Function(TookEntity took) onTookTap;

  const TookView({
    super.key,
    required this.tooks,
    required this.onTookTap,
  });

  @override
  State<TookView> createState() => _TookViewState();
}

class _TookViewState extends State<TookView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.tooks.length,
        itemBuilder: (context, index) {
          final item = widget.tooks[index];

          return InkWell(
            onTap: () => widget.onTookTap(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  subtitle: Text(
                    item.title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  title: Text(
                    item.number,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Capítulos',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(
                        '${item.listChapterIds.length}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
