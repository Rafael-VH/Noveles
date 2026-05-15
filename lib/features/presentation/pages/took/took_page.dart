import 'package:flutter/material.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/screens/screens.dart';

class TookPage extends StatefulWidget {
  const TookPage({
    super.key,
    required this.tooks,
  });

  final TookEntity tooks;

  @override
  State<TookPage> createState() => _TookPageState();
}

class _TookPageState extends State<TookPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(widget.tooks.number),
          ),

          SliverList.builder(
            itemCount: widget.tooks.listChapter.length,
            itemBuilder: (context, index) {
              var item = widget.tooks.listChapter[index];

              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterScreen(
                      i: index,
                      chapters: widget.tooks.listChapter,
                    ),
                  ),
                ),
                title: Text(
                  item.title,
                ),
                subtitle: Text(
                  item.number,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
