import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_chapter_bloc.dart';
import 'package:noveles/features/scan/presentation/screens/scan_chapter_edit_screen.dart';
import 'package:noveles/features/scan/presentation/screens/widgets/cover_picker.dart';

class ScanTookEditScreen extends StatefulWidget {
  final TookEntity? took;
  final int bookId;

  const ScanTookEditScreen({super.key, this.took, required this.bookId});

  @override
  State<ScanTookEditScreen> createState() => _ScanTookEditScreenState();
}

class _ScanTookEditScreenState extends State<ScanTookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _coverCtrl;
  bool _isSaving = false;
  List<ChapterEntity> _chapters = [];

  bool get _isEditing => widget.took != null;

  @override
  void initState() {
    super.initState();
    final t = widget.took;
    _chapters = t?.listChapter.toList() ?? [];
    _numberCtrl = TextEditingController(text: t?.number ?? '');
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _coverCtrl = TextEditingController(text: t?.cover ?? '');
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _titleCtrl.dispose();
    _coverCtrl.dispose();
    super.dispose();
  }

  // Save tomo
  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final took = TookEntity(
      id: widget.took?.id ?? DateTime.now().millisecondsSinceEpoch,
      createdAt: widget.took?.createdAt ?? DateTime.now(),
      cover: _coverCtrl.text.trim(),
      number: _numberCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      chapterCount: _chapters.length,
      bookId: widget.bookId,
      listChapter: _chapters,
    );

    final bloc = getIt<ScanTookBloc>();
    setState(() => _isSaving = true);
    final completer = Completer<ScanTookState>();
    late StreamSubscription sub;
    sub = bloc.stream.listen((s) {
      if (s is ScanTookLoaded || s is ScanTookError) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete(s);
      }
    });
    bloc.add(SaveScanTook(took, isUpdate: _isEditing));
    try {
      final result = await completer.future.timeout(const Duration(seconds: 10));
      if (result is ScanTookLoaded && mounted) {
        Navigator.pop(context, true);
      } else if (result is ScanTookError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } on TimeoutException {
      sub.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('La operación tardó demasiado'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      sub.cancel();
      bloc.close();
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Pick and upload cover image via BLoC
  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;

    final bloc = getIt<ScanTookBloc>();
    final completer = Completer<ScanTookState>();
    late StreamSubscription sub;
    sub = bloc.stream.listen((s) {
      if (s is ScanTookCoverUploaded || s is ScanTookError) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete(s);
      }
    });
    bloc.add(UploadTookCover(xFile.path));
    try {
      final result = await completer.future.timeout(const Duration(seconds: 10));
      if (result is ScanTookCoverUploaded && mounted) {
        setState(() => _coverCtrl.text = result.url);
      } else if (result is ScanTookError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } on TimeoutException {
      sub.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('La operación tardó demasiado'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      sub.cancel();
    }
  }

  // Delete chapter
  Future<void> _deleteChapter(int chapterId) async {
    if (_isSaving) return;
    final bloc = getIt<ScanChapterBloc>();
    setState(() => _isSaving = true);
    final completer = Completer<ScanChapterState>();
    late StreamSubscription sub;
    sub = bloc.stream.listen((s) {
      if (s is ScanChapterLoaded || s is ScanChapterError) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete(s);
      }
    });
    bloc.add(DeleteScanChapter(chapterId));
    try {
      final result = await completer.future.timeout(const Duration(seconds: 10));
      if (result is ScanChapterLoaded && mounted) {
        setState(() => _chapters.removeWhere((c) => c.id == chapterId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Capítulo eliminado'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      } else if (result is ScanChapterError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } on TimeoutException {
      sub.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('La operación tardó demasiado'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      sub.cancel();
      bloc.close();
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Navigate to chapter edit and await result
  Future<void> _navigateToChapterEdit({
    ChapterEntity? chapter,
    required int tookId,
  }) async {
    final result = await Navigator.push<ChapterEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanChapterEditScreen(
          chapter: chapter,
          tookId: tookId,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        final idx = _chapters.indexWhere((c) => c.id == result.id);
        if (idx >= 0) {
          _chapters[idx] = result;
        } else {
          _chapters.add(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tomo' : 'Nuevo Tomo'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Guardar'),
          ),
        ],
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: () => _navigateToChapterEdit(
                tookId: widget.took!.id,
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Number
              TextFormField(
                controller: _numberCtrl,
                decoration: const InputDecoration(labelText: 'Número'),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Requerido' : null,
              ),

              const SizedBox(height: 12),

              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),

              const SizedBox(height: 12),

              // Cover
              CoverPicker(
                controller: _coverCtrl,
                onPick: _pickCover,
                onClear: () => setState(() => _coverCtrl.clear()),
              ),

              // Show Chapters (always visible after first save)
              if (_isEditing) ...[
                const SizedBox(height: 24),

                const Divider(),

                const Text(
                  'Capítulos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // List of Chapters
                ..._chapters.map(
                  (ch) => Card(
                    child: ListTile(
                      title: Text(
                        ch.title.isNotEmpty ? ch.title : 'Cap. ${ch.number}',
                      ),
                      subtitle: Text('ID: ${ch.id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Button
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => _navigateToChapterEdit(
                              chapter: ch,
                              tookId: widget.took!.id,
                            ),
                          ),

                          // Delete Button
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _deleteChapter(ch.id),
                          ),
                        ],
                      ),
                      onTap: () => _navigateToChapterEdit(
                        chapter: ch,
                        tookId: widget.took!.id,
                      ),
                    ),
                  ),
                ),

              ],
            ],
          ),
        ),
      ),
    );
  }
}
