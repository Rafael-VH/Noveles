import 'package:flutter/material.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

class TookListSection extends StatelessWidget {
  final bool isEditing;
  final List<TookEntity> tooks;
  final int? bookId;
  final void Function() onAddTook;
  final void Function(TookEntity took, int bookId) onEditTook;
  final void Function(int tookId) onDeleteTook;

  const TookListSection({
    super.key,
    required this.isEditing,
    required this.tooks,
    required this.bookId,
    required this.onAddTook,
    required this.onEditTook,
    required this.onDeleteTook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        const Divider(),

        // Section title
        const Text(
          'Tomos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Show tooks
        if (isEditing)
          ...tooks.map(
            (took) {
              final bid = bookId;
              return Card(
                child: ListTile(
                  title: Text(
                    took.title.isNotEmpty ? took.title : 'Tomo ${took.number}',
                  ),
                  subtitle: Text('${took.listChapter.length} capítulos'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed:
                            bid != null ? () => onEditTook(took, bid) : null,
                      ),

                      // Delete Button
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => onDeleteTook(took.id),
                      ),
                    ],
                  ),
                  onTap: bid != null ? () => onEditTook(took, bid) : null,
                ),
              );
            },
          ),
      ],
    );
  }
}
