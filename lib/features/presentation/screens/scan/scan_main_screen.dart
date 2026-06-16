import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/supabase/storage_helper.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/widgets/app_drawer.dart';
import 'package:noveles/features/presentation/screens/scan/scan_book_edit_screen.dart';

class ScanMainScreen extends StatefulWidget {
  const ScanMainScreen({super.key});

  @override
  State<ScanMainScreen> createState() => _ScanMainScreenState();
}

class _ScanMainScreenState extends State<ScanMainScreen> {
  late final ScanBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ScanBloc>()..add(LoadScanBooks());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<ScanBloc, ScanState>(
        listener: (context, state) {
          // Show error message on error state
          if (state is ScanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }

          // Show success message on load or save
          if (state is ScanLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            );
          }
        },
        child: Scaffold(
          drawer: const AppDrawer(isScan: true),
          appBar: AppBar(
            title: const Text('Panel Scan'),
          ),
          body: BlocBuilder<ScanBloc, ScanState>(
            builder: (context, state) {
              // Loading State
              if (state is ScanLoading || state is ScanInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Error State
              if (state is ScanError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ScanBloc>().add(
                              LoadScanBooks(),
                            ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              // Loaded State
              final books = switch (state) {
                ScanLoaded(:final books) => books,
                ScanGenresLoaded(:final books) => books,
                _ => null,
              };

              // No Books State
              if (books == null) return const SizedBox.shrink();

              // Empty Books State
              if (books.isEmpty) {
                return const Center(
                  child: Text('No hay libros'),
                );
              }

              // Books List
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ScanBloc>().add(LoadScanBooks());
                  await context.read<ScanBloc>().stream.firstWhere(
                        (s) => s is ScanLoaded || s is ScanError,
                      );
                },
                child: ListView.builder(
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
                            imageUrl: coverUrl(book.cover),
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
                        subtitle: Text(
                          'ID: ${book.id} - ${book.tookCount} tomos',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: book.isVisible,
                              onChanged: (value) {
                                context.read<ScanBloc>().add(
                                    ToggleScanBookVisibility(book.id, value));
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onPressed: () => _editBook(context, book),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () =>
                                  _deleteBook(context, book.id, book.name),
                            ),
                          ],
                        ),
                        onTap: () => _editBook(context, book),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Add Book Button
          floatingActionButton: FloatingActionButton(
            onPressed: () => _createBook(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  // Edit Book
  void _editBook(BuildContext context, BookEntity book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _bloc,
          child: ScanBookEditScreen(book: book),
        ),
      ),
    );
  }

  // Create Book
  void _createBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _bloc,
          child: const ScanBookEditScreen(),
        ),
      ),
    );
  }

  // Delete Book
  void _deleteBook(BuildContext context, int bookId, String bookName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Eliminar "$bookName"?'),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),

          // Confirm Delete Button
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ScanBloc>().add(DeleteScanBook(bookId));
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
