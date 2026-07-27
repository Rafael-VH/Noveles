import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_bloc.dart';

class BooksTab extends StatelessWidget {
  final AdminState state;
  const BooksTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is AdminLoading || state is AdminInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AdminLoaded) {
      return BooksContent(state: state as AdminLoaded);
    }
    if (state is AdminError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text((state as AdminError).message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<AdminBloc>().add(const LoadAdminBooks()),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class BooksContent extends StatefulWidget {
  final AdminLoaded state;
  const BooksContent({super.key, required this.state});

  @override
  State<BooksContent> createState() => _BooksContentState();
}

class _BooksContentState extends State<BooksContent> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.state.books.length;
    final visible = widget.state.books.where((b) => b.isVisible).length;

    var books = widget.state.books;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      books = books.where((b) {
        return b.name.toLowerCase().contains(query) ||
            b.author.toLowerCase().contains(query);
      }).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar libros...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(Icons.visibility,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Visibles: $visible'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.menu_book,
                          color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text('Total: $total'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Chip(
                  label: Text('${books.length} de $total'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<AdminBloc>().add(const LoadAdminBooks());
              await context.read<AdminBloc>().stream.firstWhere(
                    (s) => s is AdminLoaded || s is AdminError,
                  );
            },
            child: books.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            _searchQuery.isNotEmpty
                                ? 'No se encontraron libros'
                                : 'No hay libros',
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            width: 48,
                            height: 64,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: getIt<CoverUrlService>()(book.cover),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.book,
                                size: 48,
                              ),
                            ),
                          ),
                          title: Text(
                            book.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  book.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                book.isVisible
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: book.isVisible
                                    ? Colors.green.shade700
                                    : Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                book.isVisible ? 'Visible' : 'Oculto',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: book.isVisible
                                      ? Colors.green.shade700
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  book.isVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  context.read<AdminBloc>().add(
                                        ToggleBookVisibility(
                                            book.id, !book.isVisible),
                                      );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Theme.of(context).colorScheme.error),
                                onPressed: () =>
                                    _confirmDeleteBook(context, book.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteBook(BuildContext context, int bookId) {
    final bloc = context.read<AdminBloc>();
    showConfirmationDialog(
      context: context,
      title: 'Eliminar libro',
      message: '¿Estás seguro de que deseas eliminar este libro?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(DeleteAdminBook(bookId));
      }
    });
  }
}
