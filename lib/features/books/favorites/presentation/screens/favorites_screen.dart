import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_bloc.dart';

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
                final book = state.favorites[index];
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
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
