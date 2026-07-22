import 'package:flutter/material.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

class BookTookList extends StatelessWidget {
  final List<TookEntity> tooks;
  final void Function(TookEntity) onTookTap;

  const BookTookList({
    super.key,
    required this.tooks,
    required this.onTookTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: tooks.length,
      itemBuilder: (context, index) {
        final item = tooks[index];

        return InkWell(
          onTap: () => onTookTap(item),
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
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
    );
  }
}
