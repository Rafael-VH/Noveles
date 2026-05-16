import 'package:flutter/material.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/screens/took/took_screen.dart';

class TookView extends StatefulWidget {
  const TookView({
    super.key,
    required this.books,
  });

  final BookEntity books;

  @override
  State<TookView> createState() => _TookViewState();
}

class _TookViewState extends State<TookView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        itemCount: widget.books.listTook.length,
        itemBuilder: (context, index) {
          final item = widget.books.listTook[index];

          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TookScreen(tooks: item)),
            ),
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
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  title: Text(
                    item.number,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Capítulos',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      Text(
                        '${item.listChapter.length}',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: Colors.white),
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
