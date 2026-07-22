import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:noveles/shared/presentation/widgets/snackbar_helper.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_book_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_cover_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_bloc.dart';
import 'package:noveles/features/app/presentation/widgets/app_drawer.dart';
import 'package:noveles/features/genres/presentation/genre_cubit.dart';
import 'package:noveles/features/scan/presentation/screens/scan_book_edit_screen.dart';

class ScanMainScreen extends StatefulWidget {
  const ScanMainScreen({super.key});

  @override
  State<ScanMainScreen> createState() => _ScanMainScreenState();
}

class _ScanMainScreenState extends State<ScanMainScreen> {
  late final ScanBookBloc _scanBookBloc;

  @override
  void initState() {
    super.initState();
    _scanBookBloc = getIt<ScanBookBloc>()..add(LoadScanBooks());
  }

  @override
  void dispose() {
    _scanBookBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scanBookBloc,
      child: BlocListener<ScanBookBloc, ScanBookState>(
        listener: (context, state) {
          if (state is ScanBookError) {
            showErrorSnack(context, state.message);
          }
          if (state is ScanBookLoaded && state.message != null) {
            showSuccessSnack(context, state.message!);
          }
        },
        child: Scaffold(
          drawer: const AppDrawer(isScan: true),
          appBar: AppBar(
            title: const Text('Panel Scan'),
          ),
          body: BlocBuilder<ScanBookBloc, ScanBookState>(
            builder: (context, state) {
              // Loading
              if (state is ScanBookLoading || state is ScanBookInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error
              if (state is ScanBookError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 12),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ScanBookBloc>().add(LoadScanBooks()),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              final books = switch (state) {
                ScanBookLoaded(:final books) => books,
                _ => null,
              };
              if (books == null) return const SizedBox.shrink();

              // Empty
              if (books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withAlpha(80)),
                      const SizedBox(height: 12),
                      Text('No hay libros',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              )),
                      const SizedBox(height: 4),
                      Text('Tocá + para crear tu primer libro',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              )),
                    ],
                  ),
                );
              }

              // Book list
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ScanBookBloc>().add(LoadScanBooks());
                  await context.read<ScanBookBloc>().stream.firstWhere(
                        (s) => s is ScanBookLoaded || s is ScanBookError,
                      );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _BookCard(
                      book: book,
                      onEdit: () => _editBook(context, book),
                      onDelete: () =>
                          _deleteBook(context, book.id, book.name),
                      onToggleVisibility: (value) {
                        context.read<ScanBookBloc>().add(
                              ToggleScanBookVisibility(book.id, value),
                            );
                      },
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _createBook(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _editBook(BuildContext context, BookWithRelations book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _scanBookBloc),
            BlocProvider(create: (_) => getIt<ScanCoverBloc>()),
            BlocProvider(create: (_) => getIt<ScanTookBloc>()),
            BlocProvider(create: (_) => getIt<GenreCubit>()),
          ],
          child: ScanBookEditScreen(book: book),
        ),
      ),
    );
  }

  void _createBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _scanBookBloc),
            BlocProvider(create: (_) => getIt<ScanCoverBloc>()),
            BlocProvider(create: (_) => getIt<ScanTookBloc>()),
            BlocProvider(create: (_) => getIt<GenreCubit>()),
          ],
          child: const ScanBookEditScreen(),
        ),
      ),
    );
  }

  void _deleteBook(BuildContext context, int bookId, String bookName) {
    final bloc = context.read<ScanBookBloc>();
    showConfirmationDialog(
      context: context,
      title: 'Eliminar libro',
      message: '¿Eliminar "$bookName"?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(DeleteScanBook(bookId));
      }
    });
  }
}

// ─── Book Card ─────────────────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final BookWithRelations book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(bool value) onToggleVisibility;

  const _BookCard({
    required this.book,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = getIt<CoverUrlService>()(book.cover);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 80,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: coverUrl,
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.book, size: 28,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (book.author.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      children: [
                        _StatChip(
                          icon: Icons.book_outlined,
                          label: '${book.tookCount} tomos',
                          theme: theme,
                        ),
                        const SizedBox(width: 8),
                        if (book.chapterCount > 0)
                          _StatChip(
                            icon: Icons.article_outlined,
                            label: '${book.chapterCount} caps.',
                            theme: theme,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: book.isVisible,
                    onChanged: onToggleVisibility,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  _ActionMenu(
                    onEdit: onEdit,
                    onDelete: onDelete,
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ThemeData theme;

  const _ActionMenu({
    required this.onEdit,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18,
          color: theme.colorScheme.onSurfaceVariant),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Editar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text('Eliminar',
                  style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}
