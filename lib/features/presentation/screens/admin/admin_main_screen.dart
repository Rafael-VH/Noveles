import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/supabase/storage_helper.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/main_screen.dart';
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
        if (state is AdminError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is AdminLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message!), backgroundColor: Colors.green),
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
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading || state is AdminInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<AdminBloc>().add(LoadAdminBooks()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (state is AdminLoaded) {
              final books = state.books;
              if (books.isEmpty) {
                return const Center(child: Text('No hay libros'));
              }
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: SizedBox(
                        width: 48,
                        height: 64,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: coverUrl(book.cover),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.book, size: 48),
                        ),
                      ),
                      title: Text(book.name,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle:
                          Text('ID: ${book.id} - ${book.tookCount} tomos'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editBook(context, book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteBook(context, book.id, book.name),
                          ),
                        ],
                      ),
                      onTap: () => _editBook(context, book),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createBook(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _editBook(BuildContext context, BookEntity book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminBookEditScreen(book: book),
      ),
    );
  }

  void _createBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminBookEditScreen(),
      ),
    );
  }

  void _deleteBook(BuildContext context, int bookId, String bookName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: Text('¿Eliminar "$bookName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(DeleteAdminBook(bookId));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
