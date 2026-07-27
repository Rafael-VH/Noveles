import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noveles/bootstrap/injection.dart';
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
    _chapters = t?.chapters.toList() ?? [];
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

    // Create took entity (ID=0 is a placeholder; Supabase returns the real ID)
    final took = TookEntity(
      id: widget.took?.id ?? 0,
      createdAt: widget.took?.createdAt ?? DateTime.now(),
      cover: _coverCtrl.text.trim(),
      number: _numberCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      chapterCount: _chapters.length,
      bookId: widget.bookId,
      listChapterIds: _chapters.map((c) => c.id).toList(),
    );

    final bloc = context.read<ScanTookBloc>();
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Pick and upload cover image via BLoC
  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;

    final bloc = context.read<ScanTookBloc>();
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
        builder: (_) => BlocProvider(
          create: (_) => getIt<ScanChapterBloc>(),
          child: ScanChapterEditScreen(
            chapter: chapter,
            tookId: tookId,
          ),
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
                Icon(icon, size: 18, color: theme.colorScheme.primary),
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
    return TextButton(onPressed: _save, child: const Text('Guardar'));
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing && widget.took != null
            ? (widget.took!.title.isNotEmpty
                ? widget.took!.title
                : 'Tomo ${widget.took!.number}')
            : 'Nuevo Tomo'),
        actions: [_buildSaveButton()],
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: () => _navigateToChapterEdit(
                tookId: widget.took!.id,
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Cover & Info section ──
            _sectionCard(
              title: 'Información del tomo',
              icon: Icons.book_outlined,
              children: [
                // Number + Title in a row
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
                const SizedBox(height: 16),
                CoverPicker(
                  controller: _coverCtrl,
                  onPick: _pickCover,
                  onClear: () => setState(() => _coverCtrl.clear()),
                ),
              ],
            ),

            // ── Chapters section (only when editing) ──
            if (_isEditing) ...[
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Capítulos',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_chapters.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_chapters.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'Todavía no hay capítulos',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...((_chapters.toList()
                          ..sort((a, b) => a.number.compareTo(b.number)))
                        .asMap()
                        .entries
                        .map(
                      (entry) {
                        final idx = entry.key + 1;
                        final ch = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                '$idx',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            title: Text(
                              ch.number.isNotEmpty ? ch.number : '(sin número)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: ch.title.isNotEmpty
                                ? Text(
                                    ch.title,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: () => _navigateToChapterEdit(
                                    chapter: ch,
                                    tookId: widget.took!.id,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
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
                        );
                      },
                    )),
                ],
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
