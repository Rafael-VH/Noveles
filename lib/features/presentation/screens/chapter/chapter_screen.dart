import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/pages/pages.dart';

class ChapterScreen extends StatefulWidget {
  final List<ChapterEntity> chapters;
  final int i;

  const ChapterScreen({super.key, required this.chapters, required this.i});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChapterBloc>().add(
          LoadChapterContent(
            initialIndex: widget.i,
            chapters: widget.chapters,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChapterBloc, ChapterState>(
        builder: (context, state) {
          if (state is ChapterLoading || state is ChapterInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChapterError) {
            return Center(child: Text(state.message));
          }
          if (state is ChapterLoaded) {
            return ChapterPage(
              i: state.initialIndex,
              chapters: state.chapters,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
