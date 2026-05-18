import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/supabase/storage_helper.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/profile/profile_screen.dart';
import 'package:noveles/features/presentation/screens/admin/admin_book_edit_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadAdminBooks());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        // Show error message on error state
        if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }

        // Show success message on load or save
        if (state is AdminLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            // Loading State
            if (state is AdminLoading || state is AdminInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Error State
            if (state is AdminError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AdminBloc>().add(
                            LoadAdminBooks(),
                          ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            // Loaded State
            final books = switch (state) {
              AdminLoaded(:final books) => books,
              AdminGenresLoaded(:final books) => books,
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
                context.read<AdminBloc>().add(LoadAdminBooks());
                await context.read<AdminBloc>().stream.firstWhere(
                      (s) => s is AdminLoaded || s is AdminError,
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
                          // Edit Button
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () => _editBook(context, book),
                          ),

                          // Delete Button
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
    );
  }

  // Edit Book
  void _editBook(BuildContext context, BookEntity book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminBookEditScreen(book: book),
      ),
    );
  }

  // Create Book
  void _createBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminBookEditScreen(),
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
              context.read<AdminBloc>().add(DeleteAdminBook(bookId));
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
