import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_book_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_cover_bloc.dart';
import 'package:noveles/features/scan/presentation/bloc/scan_took_bloc.dart';
import 'package:noveles/features/app/presentation/widgets/app_drawer.dart';
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
          // Show error message on error state
          if (state is ScanBookError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }

          // Show success message on load or save
          if (state is ScanBookLoaded && state.message != null) {
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
          body: BlocBuilder<ScanBookBloc, ScanBookState>(
            builder: (context, state) {
              // Loading State
              if (state is ScanBookLoading || state is ScanBookInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Error State
              if (state is ScanBookError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ScanBookBloc>().add(
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
                ScanBookLoaded(:final books) => books,
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
                  context.read<ScanBookBloc>().add(LoadScanBooks());
                  await context.read<ScanBookBloc>().stream.firstWhere(
                        (s) => s is ScanBookLoaded || s is ScanBookError,
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
                        subtitle: Text(
                          'ID: ${book.id} - ${book.tookCount} tomos',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: book.isVisible,
                              onChanged: (value) {
                                context.read<ScanBookBloc>().add(
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
  void _editBook(BuildContext context, BookWithRelations book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _scanBookBloc),
            BlocProvider(create: (_) => getIt<ScanCoverBloc>()),
            BlocProvider(create: (_) => getIt<ScanTookBloc>()),
          ],
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
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _scanBookBloc),
            BlocProvider(create: (_) => getIt<ScanCoverBloc>()),
            BlocProvider(create: (_) => getIt<ScanTookBloc>()),
          ],
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
              context.read<ScanBookBloc>().add(DeleteScanBook(bookId));
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
