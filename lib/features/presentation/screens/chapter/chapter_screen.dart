import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:noveles/core/supabase/chapter_cache.dart';
import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/pages/pages.dart';

bool _isStoragePath(String s) =>
    s.contains('/') || s.endsWith('.txt') || s.endsWith('.json');

class ChapterScreen extends StatefulWidget {
  final List<ChapterEntity> chapters;
  final int i;

  const ChapterScreen({super.key, required this.chapters, required this.i});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late List<ChapterEntity> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = List.from(widget.chapters);
    _loadContent();
  }

  Future<void> _loadContent() async {
    await Future.wait(List.generate(_chapters.length, (i) async {
      final raw = _chapters[i].content;
      if (!_isStoragePath(raw)) {
        if (mounted) {
          setState(() => _chapters[i] = ChapterEntity(
            id: _chapters[i].id, createdAt: _chapters[i].createdAt,
            number: _chapters[i].number, title: _chapters[i].title,
            content: raw, tookId: _chapters[i].tookId,
          ));
        }
        return;
      }
      try {
        String content;
        final cached = await ChapterCache.read(raw);
        if (cached != null) {
          content = cached;
        } else {
          final bytes = await supabase.storage.from('chapters').download(raw);
          content = utf8.decode(bytes);
          unawaited(ChapterCache.save(raw, bytes));
        }
        if (!mounted) return;
        setState(() {
          _chapters[i] = ChapterEntity(
            id: _chapters[i].id, createdAt: _chapters[i].createdAt,
            number: _chapters[i].number, title: _chapters[i].title,
            content: content, tookId: _chapters[i].tookId,
          );
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _chapters[i] = ChapterEntity(
            id: _chapters[i].id, createdAt: _chapters[i].createdAt,
            number: _chapters[i].number, title: _chapters[i].title,
            content: 'Error: no se pudo cargar el capítulo',
            tookId: _chapters[i].tookId,
          );
        });
      }
    }));
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
