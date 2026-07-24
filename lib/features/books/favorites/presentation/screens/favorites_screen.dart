import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/domain/book_repository.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoriteBloc>().add(
            LoadFavorites(userId: authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoriteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavorites,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is FavoriteLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(
                child: Text('No tienes favoritos aún'),
              );
            }

            return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final favorite = state.favorites[index];
                return FutureBuilder<BookWithRelations?>(
                  future: _getBookById(favorite.bookId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text('Cargando...'),
                      );
                    }

                    final book = snapshot.data;
                    if (book == null) {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: book.cover.isNotEmpty
                            ? NetworkImage(
                                getIt<CoverUrlService>()(book.cover))
                            : null,
                        child: book.cover.isEmpty
                            ? const Icon(Icons.book)
                            : null,
                      ),
                      title: Text(book.name),
                      subtitle: Text(book.author),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<BookWithRelations?> _getBookById(int bookId) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final booksRepository = getIt<BookRepository>();
      final result = await booksRepository.getBookById(bookId);
      switch (result) {
        case Ok(:final value):
          return value;
        case Err():
          return null;
      }
    }
    return null;
  }
}
