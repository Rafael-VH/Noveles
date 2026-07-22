// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_book_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_cover_bloc.dart';
import 'package:noveles/features/genres/presentation/genre_cubit.dart';
import 'package:noveles/features/genres/presentation/genre_state.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_bloc.dart';
import 'package:noveles/features/scan/presentation/screens/scan_took_edit_screen.dart';
import 'package:noveles/features/scan/presentation/screens/widgets/cover_picker.dart';
import 'package:noveles/features/scan/presentation/screens/widgets/genre_selector.dart';
import 'package:noveles/features/scan/presentation/screens/widgets/took_list_section.dart';

class ScanBookEditScreen extends StatefulWidget {
  final BookWithRelations? book;

  const ScanBookEditScreen({super.key, this.book});

  @override
  State<ScanBookEditScreen> createState() => _ScanBookEditScreenState();
}

class _ScanBookEditScreenState extends State<ScanBookEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _coverCtrl;
  late TextEditingController _shortCtrl;
  late TextEditingController _alternativeCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _authorCtrl;
  late TextEditingController _countryCtrl;
  String _state = '';
  String _type = '';
  late TextEditingController _releaseCtrl;
  late TextEditingController _sourceCtrl;
  late TextEditingController _linkCtrl;
  List<GenreEntity> _allGenres = [];
  Set<int> _selectedGenreIds = {};
  List<TookEntity> _tooks = [];
  int? _bookId;
  bool _isSaving = false;

  bool get _isEditing => _bookId != null;

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
    _state = b?.state ?? '';
    _type = b?.type ?? '';
    _releaseCtrl = TextEditingController(text: b?.release ?? '');
    _sourceCtrl = TextEditingController(text: b?.source ?? '');
    _linkCtrl = TextEditingController(text: b?.link ?? '');
    _selectedGenreIds = b?.listGenreIds.toSet() ?? {};
    _bookId = widget.book?.id;
    _tooks = widget.book?.listTook.toList() ?? [];
    context.read<GenreCubit>().loadGenres();
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
    _releaseCtrl.dispose();
    _sourceCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  // Pick cover image
  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      context.read<ScanCoverBloc>().add(UploadScanCover(xFile.path));
    }
  }

  // Save book
  Future<BookEntity?> _saveBook() async {
    // Prevent multiple saves
    if (_isSaving) return null;

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) return null;

    // Create book entity (ID=0 is a placeholder; Supabase returns the real ID)
    final book = BookEntity(
      id: widget.book?.id ?? 0,
      createdAt: widget.book?.createdAt ?? DateTime.now(),
      cover: _coverCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      short: _shortCtrl.text.trim(),
      alternative: _alternativeCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      authorId: widget.book?.authorId ?? 0,
      author: _authorCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      state: _state,
      type: _type,
      release: _releaseCtrl.text.trim(),
      tookCount: widget.book?.tookCount ?? 0,
      chapterCount: widget.book?.chapterCount ?? 0,
      source: _sourceCtrl.text.trim(),
      link: _linkCtrl.text.trim(),
      isFavorite: widget.book?.isFavorite ?? false,
      isVisible: widget.book?.isVisible ?? false,
      listLabelIds: widget.book?.listLabelIds ?? [],
      listGenreIds: _selectedGenreIds.toList(),
      listTookIds: _tooks.map((t) => t.id).toList(),
    );

    // Save book
    if (mounted) setState(() => _isSaving = true);

    // Listen for result
    final bloc = context.read<ScanBookBloc>();
    final completer = Completer<ScanBookState>();
    late StreamSubscription sub;
    sub = bloc.stream.listen((s) {
      if (s is ScanBookLoaded || s is ScanBookError) {
        sub.cancel();
        if (!completer.isCompleted) completer.complete(s);
      }
    });
    bloc.add(SaveScanBook(book, isUpdate: _isEditing));

    try {
      final result = await completer.future.timeout(const Duration(seconds: 10));
      if (result is ScanBookLoaded && mounted) {
        if (_isEditing) return widget.book;
        // New book — capture the real DB-generated ID from the reloaded list
        final match = result.books.firstWhere(
          (b) => b.name == book.name && b.author == book.author,
          orElse: () => result.books.last,
        );
        _bookId = match.id;
        return match;
      } else if (result is ScanBookError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result.message),
              backgroundColor: Theme.of(context).colorScheme.error),
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
    return null;
  }

  // Save and exit
  Future<void> _save() async {
    final saved = await _saveBook();
    if (saved != null && mounted) Navigator.pop(context);
  }

  // Navigate to took edit (save book first if it's new)
  Future<void> _addTook() async {
    int bookId;
    if (_bookId != null) {
      bookId = _bookId!;
    } else {
      // New book — save first to get a real book ID
      final saved = await _saveBook();
      if (saved == null || _bookId == null) return;
      bookId = _bookId!;
    }
    final refreshed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<ScanTookBloc>(),
          child: ScanTookEditScreen(bookId: bookId),
        ),
      ),
    );
    if (refreshed == true && mounted) {
      context.read<ScanBookBloc>().add(LoadScanBooks());
    }
  }

  // ─── Section helpers ───────────────────────────────────────────────

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
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

  Widget _buildCoverSection() {
    return _sectionCard(
      title: 'Portada',
      icon: Icons.image_outlined,
      children: [
        CoverPicker(
          controller: _coverCtrl,
          onPick: _pickCover,
          onClear: () => setState(() => _coverCtrl.clear()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v?.trim().isEmpty == true ? 'Requerido' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _authorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _countryCtrl,
                decoration: const InputDecoration(
                  labelText: 'País',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return _sectionCard(
      title: 'Descripción',
      icon: Icons.description_outlined,
      children: [
        TextFormField(
          maxLines: 5,
          controller: _descriptionCtrl,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _shortCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre corto',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _alternativeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre alternativo',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassificationSection() {
    return _sectionCard(
      title: 'Clasificación',
      icon: Icons.tune_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _state,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: '', child: Text('Seleccioná...')),
                  DropdownMenuItem(value: 'Emisión', child: Text('Emisión')),
                  DropdownMenuItem(value: 'Finalizado', child: Text('Finalizado')),
                  DropdownMenuItem(value: 'Pausado', child: Text('Pausado')),
                  DropdownMenuItem(value: 'Abandonado', child: Text('Abandonado')),
                ],
                onChanged: (v) => setState(() => _state = v ?? ''),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: '', child: Text('Seleccioná...')),
                  DropdownMenuItem(value: 'Web', child: Text('Web Novel')),
                  DropdownMenuItem(value: 'Ligera', child: Text('Light Novel')),
                ],
                onChanged: (v) => setState(() => _type = v ?? ''),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _releaseCtrl,
                decoration: const InputDecoration(
                  labelText: 'Año',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sourceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fuente',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _linkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Link',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenresSection() {
    return _sectionCard(
      title: 'Géneros',
      icon: Icons.label_outline,
      children: [
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
      ],
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GenreCubit, GenreState>(
          listener: (context, state) {
            if (state is GenreLoaded) {
              setState(() => _allGenres = state.genres);
            }
          },
        ),
        BlocListener<ScanCoverBloc, ScanCoverState>(
          listener: (context, state) {
            if (state is ScanCoverUploaded) {
              _coverCtrl.text = state.filename;
            } else if (state is ScanCoverError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
        BlocListener<ScanBookBloc, ScanBookState>(
          listener: (context, state) {
            if (state is ScanBookLoaded && !_isSaving) {
              if (state.books.isEmpty) return;
              final match = state.books.firstWhere(
                (b) =>
                    b.id == _bookId ||
                    (b.name == _nameCtrl.text.trim() &&
                        b.author == _authorCtrl.text.trim()),
                orElse: () => state.books.last,
              );
              _tooks = match.listTook;
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing && widget.book != null
              ? widget.book!.name
              : 'Nuevo Libro'),
          actions: [_buildSaveButton()],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCoverSection(),
              const SizedBox(height: 16),
              _buildDescriptionSection(),
              const SizedBox(height: 16),
              _buildClassificationSection(),
              const SizedBox(height: 16),
              _buildGenresSection(),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                TookListSection(
                  isEditing: true,
                  tooks: _tooks,
                  bookId: _bookId,
                  onAddTook: _addTook,
                  onEditTook: (took, bookId) async {
                    final refreshed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => getIt<ScanTookBloc>(),
                          child: ScanTookEditScreen(
                            took: took,
                            bookId: bookId,
                          ),
                        ),
                      ),
                    );
                    if (refreshed == true && mounted) {
                      context.read<ScanBookBloc>().add(LoadScanBooks());
                    }
                  },
                  onDeleteTook: (tookId) async {
                    final bloc = context.read<ScanTookBloc>();
                    final completer = Completer<ScanTookState>();
                    late StreamSubscription sub;
                    sub = bloc.stream.listen((s) {
                      if (s is ScanTookLoaded || s is ScanTookError) {
                        sub.cancel();
                        if (!completer.isCompleted) completer.complete(s);
                      }
                    });
                    bloc.add(DeleteScanTook(tookId));
                    try {
                      final result = await completer.future
                          .timeout(const Duration(seconds: 10));
                      if (result is ScanTookLoaded && mounted) {
                        setState(() =>
                            _tooks.removeWhere((t) => t.id == tookId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(result.message ?? 'Tomo eliminado'),
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                          ),
                        );
                      } else if (result is ScanTookError && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    } on TimeoutException {
                      sub.cancel();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('La operación tardó demasiado'),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
              // Bottom padding
              const SizedBox(height: 32),
            ],
          ),
        ),
        floatingActionButton: _isEditing
            ? FloatingActionButton(
                onPressed: _addTook,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
