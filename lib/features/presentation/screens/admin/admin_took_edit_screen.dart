import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/admin/admin_chapter_edit_screen.dart';

class AdminTookEditScreen extends StatefulWidget {
  final TookEntity? took;
  final int bookId;

  const AdminTookEditScreen({super.key, this.took, required this.bookId});

  @override
  State<AdminTookEditScreen> createState() => _AdminTookEditScreenState();
}

class _AdminTookEditScreenState extends State<AdminTookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _coverCtrl;
  bool _isSaving = false;

  bool get _isEditing => widget.took != null;

  @override
  void initState() {
    super.initState();
    final t = widget.took;
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
      chapterCount: widget.took?.chapterCount ?? '',
      bookId: widget.bookId,
      listChapter: widget.took?.listChapter ?? [],
    );
    setState(() => _isSaving = true);
    try {
      final bloc = context.read<AdminBloc>();
      final future = bloc.stream.firstWhere((s) => s is! AdminLoading);
      bloc.add(SaveAdminTook(took, isUpdate: _isEditing));
      final result = await future;
      if (result is AdminLoaded && mounted) {
        Navigator.pop(context);
      } else if (result is AdminError && mounted) {
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
      final bloc = context.read<AdminBloc>();
      final future = bloc.stream.firstWhere((s) => s is! AdminLoading);
      bloc.add(DeleteAdminChapter(chapterId));
      final result = await future;
      if (result is AdminLoaded && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Capítulo eliminado'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      } else if (result is AdminError && mounted) {
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

              const SizedBox(height: 12),

              // Show Chapters if editing
              if (_isEditing) ...[
                const SizedBox(height: 24),

                const Divider(),

                const Text(
                  'Capítulos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // List of Chapters
                ...?widget.took?.listChapter.map(
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
                                builder: (_) => AdminChapterEditScreen(
                                  chapter: ch,
                                  tookId: widget.took!.id,
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
                          builder: (_) => AdminChapterEditScreen(
                            chapter: ch,
                            tookId: widget.took!.id,
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
                      builder: (_) => AdminChapterEditScreen(
                        tookId: widget.took!.id,
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
