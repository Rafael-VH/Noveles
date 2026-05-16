import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noveles/core/supabase/storage_helper.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/admin/admin_took_edit_screen.dart';

class AdminBookEditScreen extends StatefulWidget {
  final BookEntity? book;

  const AdminBookEditScreen({super.key, this.book});

  @override
  State<AdminBookEditScreen> createState() => _AdminBookEditScreenState();
}

class _AdminBookEditScreenState extends State<AdminBookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _coverCtrl;
  late TextEditingController _shortCtrl;
  late TextEditingController _alternativeCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _authorCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _typeCtrl;
  late TextEditingController _releaseCtrl;
  late TextEditingController _sourceCtrl;
  late TextEditingController _linkCtrl;
  List<GenreEntity> _allGenres = [];
  Set<int> _selectedGenreIds = {};
  bool _isSaving = false;
  StreamSubscription? _stateSub;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _coverCtrl = TextEditingController(text: b?.cover ?? '');
    _shortCtrl = TextEditingController(text: b?.short ?? '');
    _alternativeCtrl = TextEditingController(text: b?.alternative ?? '');
    _descriptionCtrl = TextEditingController(text: b?.description ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _countryCtrl = TextEditingController(text: b?.country ?? '');
    _stateCtrl = TextEditingController(text: b?.state ?? '');
    _typeCtrl = TextEditingController(text: b?.type ?? '');
    _releaseCtrl = TextEditingController(text: b?.release ?? '');
    _sourceCtrl = TextEditingController(text: b?.source ?? '');
    _linkCtrl = TextEditingController(text: b?.link ?? '');
    _selectedGenreIds = b?.listGenre.map((g) => g.id).toSet() ?? {};
    _stateSub = context.read<AdminBloc>().stream.listen((state) {
      if (state is AdminGenresLoaded && mounted) {
        setState(() => _allGenres = state.genres);
      } else if (state is AdminCoverUploaded && mounted) {
        setState(() => _coverCtrl.text = state.filename);
      }
    });
    context.read<AdminBloc>().add(LoadAdminGenres());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _coverCtrl.dispose();
    _shortCtrl.dispose();
    _alternativeCtrl.dispose();
    _descriptionCtrl.dispose();
    _authorCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _typeCtrl.dispose();
    _releaseCtrl.dispose();
    _sourceCtrl.dispose();
    _linkCtrl.dispose();
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      context.read<AdminBloc>().add(UploadAdminCover(xFile.path));
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final book = BookEntity(
      id: widget.book?.id ?? DateTime.now().millisecondsSinceEpoch,
      createdAt: widget.book?.createdAt ?? DateTime.now(),
      cover: _coverCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      short: _shortCtrl.text.trim(),
      alternative: _alternativeCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      authorId: widget.book?.authorId ?? 0,
      author: _authorCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      type: _typeCtrl.text.trim(),
      release: _releaseCtrl.text.trim(),
      tookCount: widget.book?.tookCount ?? '',
      chapterCount: widget.book?.chapterCount ?? '',
      source: _sourceCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
      isFavorite: widget.book?.isFavorite ?? false,
      listGenre: _allGenres.where((g) => _selectedGenreIds.contains(g.id)).toList(),
      listTook: widget.book?.listTook ?? [],
    );
    setState(() => _isSaving = true);
    try {
      final bloc = context.read<AdminBloc>();
      final future = bloc.stream.firstWhere((s) => s is! AdminLoading);
      bloc.add(SaveAdminBook(book, isUpdate: _isEditing));
      final result = await future;
      if (result is AdminLoaded && mounted) {
        Navigator.pop(context);
      } else if (result is AdminError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
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
        title: Text(_isEditing ? 'Editar Libro' : 'Nuevo Libro'),
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
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Requerido' : null),
              const SizedBox(height: 8),
              const Text('Cover',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_coverCtrl.text.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    coverUrl(_coverCtrl.text),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickCover,
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar imagen'),
                  ),
                  if (_coverCtrl.text.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _coverCtrl.clear()),
                      child: const Text('Quitar'),
                    ),
                ],
              ),
              if (_coverCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_coverCtrl.text,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              TextFormField(
                  controller: _shortCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre corto')),
              TextFormField(
                  controller: _alternativeCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nombre alternativo')),
              TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3),
              TextFormField(
                  controller: _authorCtrl,
                  decoration: const InputDecoration(labelText: 'Autor')),
              TextFormField(
                  controller: _countryCtrl,
                  decoration: const InputDecoration(labelText: 'País')),
              TextFormField(
                  controller: _stateCtrl,
                  decoration: const InputDecoration(labelText: 'Estado')),
              TextFormField(
                  controller: _typeCtrl,
                  decoration: const InputDecoration(labelText: 'Tipo')),
              TextFormField(
                  controller: _releaseCtrl,
                  decoration: const InputDecoration(labelText: 'Lanzamiento')),
              TextFormField(
                  controller: _sourceCtrl,
                  decoration: const InputDecoration(labelText: 'Fuente')),
              TextFormField(
                  controller: _linkCtrl,
                  decoration: const InputDecoration(labelText: 'Link')),
              const SizedBox(height: 16),
              const Text('Géneros',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_allGenres.isEmpty)
                const Text('Cargando géneros...',
                    style: TextStyle(color: Colors.grey))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _allGenres.map((genre) => FilterChip(
                    label: Text(genre.name),
                    selected: _selectedGenreIds.contains(genre.id),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedGenreIds.add(genre.id);
                        } else {
                          _selectedGenreIds.remove(genre.id);
                        }
                      });
                    },
                  )).toList(),
                ),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                const Divider(),
                const Text('Tomos',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...?widget.book?.listTook.map((took) => Card(
                      child: ListTile(
                        title: Text(took.title.isNotEmpty
                            ? took.title
                            : 'Tomo ${took.number}'),
                        subtitle: Text('${took.listChapter.length} capítulos'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminTookEditScreen(
                                        took: took, bookId: widget.book!.id),
                                  )),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context
                                    .read<AdminBloc>()
                                    .add(DeleteAdminTook(took.id));
                              },
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminTookEditScreen(
                                  took: took, bookId: widget.book!.id),
                            )),
                      ),
                    )),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminTookEditScreen(bookId: widget.book!.id),
                      )),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir Tomo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
