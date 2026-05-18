import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/admin/admin_took_edit_screen.dart';
import 'package:noveles/features/presentation/screens/admin/widgets/cover_picker.dart';
import 'package:noveles/features/presentation/screens/admin/widgets/genre_selector.dart';
import 'package:noveles/features/presentation/screens/admin/widgets/took_list_section.dart';

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
  List<TookEntity> _tooks = [];
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
    _tooks = b?.listTook ?? [];
    _stateSub = context.read<AdminBloc>().stream.listen((state) {
      if (state is AdminGenresLoaded && mounted) {
        setState(() => _allGenres = state.genres);
      } else if (state is AdminCoverUploaded && mounted) {
        setState(() => _coverCtrl.text = state.filename);
      } else if (state is AdminLoaded && mounted) {
        final match = state.books.firstWhere(
          (b) =>
              b.id == widget.book?.id ||
              (b.name == _nameCtrl.text.trim() &&
                  b.author == _authorCtrl.text.trim()),
          orElse: () => _isEditing ? widget.book! : state.books.last,
        );
        _tooks = match.listTook;
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

  // Pick cover image
  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      context.read<AdminBloc>().add(UploadAdminCover(xFile.path));
    }
  }

  // Save book
  Future<BookEntity?> _saveBook() async {
    // Prevent multiple saves
    if (_isSaving) return null;

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) return null;

    // Create book entity
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
      listGenre:
          _allGenres.where((g) => _selectedGenreIds.contains(g.id)).toList(),
      listTook: widget.book?.listTook ?? [],
    );

    // Save book
    setState(() => _isSaving = true);

    // Listen for result
    try {
      final bloc = context.read<AdminBloc>();
      final future = bloc.stream.firstWhere((s) => s is! AdminLoading);
      bloc.add(SaveAdminBook(book, isUpdate: _isEditing));
      final result = await future;
      if (result is AdminLoaded && mounted) {
        return _isEditing
            ? widget.book
            : result.books.firstWhere(
                (b) => b.name == book.name && b.author == book.author,
                orElse: () => result.books.last,
              );
      } else if (result is AdminError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result.message),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
    return null;
  }

  // Save and add tomo
  Future<void> _saveAndAddTomo() async {
    // Save book first
    final saved = await _saveBook();

    // If save was successful, navigate to tomo edit screen
    if (saved != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminTookEditScreen(bookId: saved.id),
        ),
      );
    }
  }

  // Delete tomo
  Future<void> _save() async {
    final saved = await _saveBook();
    if (saved != null && mounted) Navigator.pop(context);
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
              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Requerido' : null,
              ),

              const SizedBox(height: 12),

              // Cover
              CoverPicker(
                controller: _coverCtrl,
                onPick: _pickCover,
                onClear: () => setState(() => _coverCtrl.clear()),
              ),

              const SizedBox(height: 12),

              // Short Name
              TextFormField(
                controller: _shortCtrl,
                decoration: const InputDecoration(labelText: 'Nombre corto'),
              ),

              const SizedBox(height: 12),

              // Alternative Name
              TextFormField(
                controller: _alternativeCtrl,
                decoration:
                    const InputDecoration(labelText: 'Nombre alternativo'),
              ),

              const SizedBox(height: 12),

              // Description
              TextFormField(
                maxLines: 3,
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),

              const SizedBox(height: 12),

              // Author
              TextFormField(
                controller: _authorCtrl,
                decoration: const InputDecoration(labelText: 'Autor'),
              ),

              const SizedBox(height: 12),

              // Country
              TextFormField(
                controller: _countryCtrl,
                decoration: const InputDecoration(labelText: 'País'),
              ),

              const SizedBox(height: 12),

              // State
              TextFormField(
                controller: _stateCtrl,
                decoration: const InputDecoration(labelText: 'Estado'),
              ),

              const SizedBox(height: 12),

              // Type
              TextFormField(
                controller: _typeCtrl,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),

              const SizedBox(height: 12),

              // Release
              TextFormField(
                controller: _releaseCtrl,
                decoration: const InputDecoration(labelText: 'Lanzamiento'),
              ),

              const SizedBox(height: 12),

              // Source
              TextFormField(
                controller: _sourceCtrl,
                decoration: const InputDecoration(labelText: 'Fuente'),
              ),

              const SizedBox(height: 12),

              // Link
              TextFormField(
                controller: _linkCtrl,
                decoration: const InputDecoration(labelText: 'Link'),
              ),

              const SizedBox(height: 16),

              // Genres
              GenreSelector(
                genres: _allGenres,
                selectedIds: _selectedGenreIds,
                onToggle: (id, selected) {
                  setState(() {
                    if (selected) {
                      _selectedGenreIds.add(id);
                    } else {
                      _selectedGenreIds.remove(id);
                    }
                  });
                },
              ),

              const SizedBox(height: 12),

              // Took List
              TookListSection(
                isEditing: _isEditing,
                tooks: _tooks,
                bookId: widget.book?.id,
                onAddTook: _isEditing
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminTookEditScreen(bookId: widget.book!.id),
                          ),
                        )
                    : _saveAndAddTomo,
                onEditTook: (took, bookId) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminTookEditScreen(took: took, bookId: bookId),
                  ),
                ),
                onDeleteTook: (tookId) {
                  context.read<AdminBloc>().add(DeleteAdminTook(tookId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
