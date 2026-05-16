import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';

class AdminChapterEditScreen extends StatefulWidget {
  final ChapterEntity? chapter;
  final int tookId;

  const AdminChapterEditScreen({super.key, this.chapter, required this.tookId});

  @override
  State<AdminChapterEditScreen> createState() => _AdminChapterEditScreenState();
}

class _AdminChapterEditScreenState extends State<AdminChapterEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;

  bool get _isEditing => widget.chapter != null;

  @override
  void initState() {
    super.initState();
    final c = widget.chapter;
    _numberCtrl = TextEditingController(text: c?.number ?? '');
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _contentCtrl = TextEditingController(text: c?.content ?? '');
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final chapter = ChapterEntity(
      id: widget.chapter?.id ?? DateTime.now().millisecondsSinceEpoch,
      createdAt: widget.chapter?.createdAt ?? DateTime.now(),
      number: _numberCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text,
      tookId: widget.tookId,
    );
    context
        .read<AdminBloc>()
        .add(SaveAdminChapter(chapter, isUpdate: _isEditing));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              TextFormField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(labelText: 'Número')),
              TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 16),
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
    );
  }
}
