import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/scan/scan_chapter_edit_screen.dart';

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
  TookEntity? _currentTook;
  StreamSubscription? _stateSub;

  bool get _isEditing => widget.took != null;

  @override
  void initState() {
    super.initState();
    final t = widget.took;
    _currentTook = t;
    _numberCtrl = TextEditingController(text: t?.number ?? '');
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _coverCtrl = TextEditingController(text: t?.cover ?? '');
    _stateSub = context.read<ScanBloc>().stream.listen((state) {
      if (state is ScanLoaded && mounted) {
        final target = _currentTook;
        if (target != null) {
          for (final b in state.books) {
            for (final t2 in b.listTook) {
              if (t2.id == target.id) {
                setState(() => _currentTook = t2);
                return;
              }
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _titleCtrl.dispose();
    _coverCtrl.dispose();
    _stateSub?.cancel();
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
      chapterCount: widget.took?.chapterCount ?? '',
      bookId: widget.bookId,
      listChapter: widget.took?.listChapter ?? [],
    );
    setState(() => _isSaving = true);
    try {
      final bloc = context.read<ScanBloc>();
      final future = bloc.stream.firstWhere((s) => s is! ScanLoading);
      bloc.add(SaveScanTook(took, isUpdate: _isEditing));
      final result = await future;
      if (result is ScanLoaded && mounted) {
        if (_isEditing) {
          Navigator.pop(context);
        } else {
          final match = result.books.expand((b) => b.listTook).firstWhere(
                (t) => t.number == took.number,
                orElse: () => result.books.expand((b) => b.listTook).last,
              );
          setState(() => _currentTook = match);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tomo creado'),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } else if (result is ScanError && mounted) {
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

  // Delete chapter
  Future<void> _deleteChapter(int chapterId) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final bloc = context.read<ScanBloc>();
      final future = bloc.stream.firstWhere((s) => s is! ScanLoading);
      bloc.add(DeleteScanChapter(chapterId));
      final result = await future;
      if (result is ScanLoaded && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Capítulo eliminado'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      } else if (result is ScanError && mounted) {
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

              // Cover URL
              TextFormField(
                controller: _coverCtrl,
                decoration: const InputDecoration(labelText: 'Cover URL'),
              ),

              // Show Chapters (always visible after first save)
              if (_currentTook != null) ...[
                const SizedBox(height: 24),

                const Divider(),

                const Text(
                  'Capítulos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // List of Chapters
                ..._currentTook!.listChapter.map(
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
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScanChapterEditScreen(
                                  chapter: ch,
                                  tookId: _currentTook!.id,
                                ),
                              ),
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanChapterEditScreen(
                            chapter: ch,
                            tookId: _currentTook!.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Add Chapter Button
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanChapterEditScreen(
                        tookId: _currentTook!.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Capítulo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
