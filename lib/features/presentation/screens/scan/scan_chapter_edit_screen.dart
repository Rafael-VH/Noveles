import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/presentation/bloc/scan/scan_chapter_bloc.dart';

class ScanChapterEditScreen extends StatefulWidget {
  final ChapterEntity? chapter;
  final int tookId;

  const ScanChapterEditScreen({super.key, this.chapter, required this.tookId});

  @override
  State<ScanChapterEditScreen> createState() => _ScanChapterEditScreenState();
}

class _ScanChapterEditScreenState extends State<ScanChapterEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _isSaving = false;
  late final ScanChapterBloc _scanChapterBloc;

  bool get _isEditing => widget.chapter != null;

  @override
  void initState() {
    super.initState();
    final c = widget.chapter;
    _numberCtrl = TextEditingController(text: c?.number ?? '');
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _contentCtrl = TextEditingController(text: c?.content ?? '');
    _scanChapterBloc = getIt<ScanChapterBloc>();
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _scanChapterBloc.close();
    super.dispose();
  }

  // Save chapter
  Future<void> _save() async {
    // Prevent multiple saves
    if (_isSaving) return;

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Create chapter entity
    final chapter = ChapterEntity(
      id: widget.chapter?.id ?? DateTime.now().millisecondsSinceEpoch,
      createdAt: widget.chapter?.createdAt ?? DateTime.now(),
      number: _numberCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text,
      tookId: widget.tookId,
    );

    // Save chapter
    setState(() => _isSaving = true);

    try {
      final future = _scanChapterBloc.stream.firstWhere(
        (s) => s is ScanChapterLoaded || s is ScanChapterError,
      );
      _scanChapterBloc.add(SaveScanChapter(chapter, isUpdate: _isEditing));
      final result = await future;
      if (result is ScanChapterLoaded && mounted) {
        Navigator.pop(context, chapter);
      } else if (result is ScanChapterError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scanChapterBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Capítulo' : 'Nuevo Capítulo'),
          actions: [
            TextButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
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
                ),

                const SizedBox(height: 8),

                // Title
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),

                const SizedBox(height: 16),

                // Content
                TextFormField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 20,
                  validator: (v) =>
                      v?.isEmpty == true ? 'El contenido es requerido' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
