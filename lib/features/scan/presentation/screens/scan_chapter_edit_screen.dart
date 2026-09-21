import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_content_type.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_chapter_bloc.dart';

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
  late TextEditingController _inlineCtrl;
  String _uploadedFileName = '';
  bool _isSaving = false;
  late ChapterContentType _contentType;

  bool get _isEditing => widget.chapter != null;

  bool get _isStorage => _contentType == ChapterContentType.storagePath;

  @override
  void initState() {
    super.initState();
    final c = widget.chapter;
    _contentType = c?.contentType ?? ChapterContentType.storagePath;

    final storedContent = c?.content ?? '';
    _numberCtrl = TextEditingController(text: c?.number ?? '');
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _contentCtrl = TextEditingController(text: _isStorage ? storedContent : '');
    _inlineCtrl = TextEditingController(text: _isStorage ? '' : storedContent);
    _uploadedFileName = _isStorage ? _extractFileName(storedContent) : '';
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _inlineCtrl.dispose();
    super.dispose();
  }

  /// Extract a display-friendly filename from a URL or storage path.
  String _extractFileName(String value) {
    if (value.isEmpty) return '';
    // If it looks like a URL (contains /)
    if (value.contains('/')) {
      return value.split('/').last;
    }
    // If it ends with .txt but is not a URL (just a filename)
    if (value.endsWith('.txt')) return value;
    // Otherwise it's inline content — show nothing special
    return '';
  }

  /// Switch between inline text and Storage-backed content.
  void _onContentTypeChanged(Set<ChapterContentType> selection) {
    if (selection.isEmpty) return;
    setState(() {
      _contentType = selection.first;
      if (_isStorage) _uploadedFileName = _extractFileName(_contentCtrl.text);
    });
  }

  // Pick and upload content file via BLoC
  Future<void> _pickContentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'txt'],
      );

      if (result == null || !mounted) return;

      final filePath = result.files.single.path;

      if (filePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No se pudo acceder al archivo'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      final fileName = result.files.single.name;
      final bloc = context.read<ScanChapterBloc>();
      final completer = Completer<ScanChapterState>();
      late StreamSubscription sub;
      sub = bloc.stream.listen((s) {
        if (s is ScanChapterContentUploaded || s is ScanChapterError) {
          sub.cancel();
          if (!completer.isCompleted) completer.complete(s);
        }
      });
      bloc.add(UploadChapterFile(filePath));
      try {
        final uploadResult = await completer.future.timeout(const Duration(seconds: 10));
        if (uploadResult is ScanChapterContentUploaded && mounted) {
          setState(() {
            _contentCtrl.text = uploadResult.url;
            _uploadedFileName = fileName;
          });
        } else if (uploadResult is ScanChapterError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uploadResult.message),
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar archivo: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Save chapter
  Future<void> _save() async {
    // Prevent multiple saves
    if (_isSaving) return;

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Create chapter entity (ID=0 is a placeholder; Supabase returns the real ID)
    final chapter = ChapterEntity(
      id: widget.chapter?.id ?? 0,
      createdAt: widget.chapter?.createdAt ?? DateTime.now(),
      number: _numberCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      content: _isStorage ? _contentCtrl.text : _inlineCtrl.text,
      tookId: widget.tookId,
      contentType: _contentType,
    );

    // Save chapter
    final bloc = context.read<ScanChapterBloc>();
    setState(() => _isSaving = true);

    final completer = Completer<ScanChapterState>();
    late StreamSubscription sub;
    sub = bloc.stream.listen((s) {
      if (s is ScanChapterLoaded || s is ScanChapterError) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete(s);
      }
    });
    bloc.add(SaveScanChapter(chapter, isUpdate: _isEditing));
    try {
      final result = await completer.future.timeout(const Duration(seconds: 10));
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Section helpers ───────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    if (_isSaving) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return TextButton(
      onPressed: _save,
      child: const Text('Guardar'),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = _contentCtrl.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing && widget.chapter != null
            ? (widget.chapter!.title.isNotEmpty
                ? widget.chapter!.title
                : 'Cap. ${widget.chapter!.number}')
            : 'Nuevo Capítulo'),
        actions: [_buildSaveButton()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Info section ──
            _sectionCard(
              title: 'Información del capítulo',
              icon: Icons.article_outlined,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _numberCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Número',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.trim().isEmpty == true ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Content section ──
            _sectionCard(
              title: 'Contenido del capítulo',
              icon: Icons.description_outlined,
              children: [
                // Storage file vs inline text
                SegmentedButton<ChapterContentType>(
                  segments: const [
                    ButtonSegment(
                      value: ChapterContentType.storagePath,
                      icon: Icon(Icons.cloud_upload_outlined),
                      label: Text('Archivo'),
                    ),
                    ButtonSegment(
                      value: ChapterContentType.inline,
                      icon: Icon(Icons.edit_note),
                      label: Text('Texto inline'),
                    ),
                  ],
                  selected: {_contentType},
                  onSelectionChanged: _onContentTypeChanged,
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 16),

                // Inline mode: the chapter text lives in the content column
                if (!_isStorage)
                  TextFormField(
                    controller: _inlineCtrl,
                    minLines: 8,
                    maxLines: 20,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Texto del capítulo',
                      hintText: 'Escribí o pegá el contenido del capítulo',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'El contenido no puede estar vacío'
                        : null,
                  ),

                // Storage mode: pick and upload a .md/.txt file
                if (_isStorage && hasContent)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: Icon(
                        Icons.insert_drive_file,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        _uploadedFileName.isNotEmpty
                            ? _uploadedFileName
                            : _contentCtrl.text,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: TextButton(
                        onPressed: _pickContentFile,
                        child: const Text('Reemplazar'),
                      ),
                    ),
                  ),
                if (_isStorage && !hasContent)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file_outlined,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ningún archivo seleccionado',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_isStorage) const SizedBox(height: 12),
                if (_isStorage)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickContentFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Seleccionar archivo .md o .txt'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (_isStorage && !hasContent)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'El contenido se subirá a Supabase Storage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
