import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:noveles/features/data/local/models/chapter_local_model.dart';
import 'package:noveles/features/presentation/pages/pages.dart';

class ChapterScreen extends StatefulWidget {
  final List<ChapterLocalModel> chapters;
  final int i;

  const ChapterScreen({super.key, required this.chapters, required this.i});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late List<ChapterLocalModel> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = List.from(widget.chapters);
    _loadContent();
  }

  Future<void> _loadContent() async {
    for (int i = 0; i < _chapters.length; i++) {
      try {
        final String content = await rootBundle.loadString(_chapters[i].content);
        setState(() {
          _chapters[i] = _chapters[i].copyWith(content: content);
        });
      } catch (e) {
        setState(() {
          _chapters[i] = _chapters[i].copyWith(content: 'Error: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChapterPage(
        i: widget.i,
        chapters: _chapters,
      ),
    );
  }
}
