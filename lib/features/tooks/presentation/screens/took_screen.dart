import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/chapter_screen.dart';

class TookScreen extends StatefulWidget {
  final TookEntity tooks;

  const TookScreen({super.key, required this.tooks});

  @override
  State<TookScreen> createState() => _TookScreenState();
}

class _TookScreenState extends State<TookScreen> {
  /// Runtime cast: data layer hydrates TookModel with full chapters.
  List<ChapterEntity> get _chapters =>
      (widget.tooks is TookModel) ? (widget.tooks as TookModel).chapters : [];

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(widget.tooks.number),
            ),

            SliverList.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final item = chapters[index];

                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => getIt<ChapterBloc>(),
                        child: ChapterScreen(
                          i: index,
                          chapters: chapters,
                        ),
                      ),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.number),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
