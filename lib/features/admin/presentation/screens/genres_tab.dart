import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/shared/presentation/widgets/snackbar_helper.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/genres/presentation/bloc/genre_bloc.dart';

class GenresTab extends StatefulWidget {
  const GenresTab({super.key});

  @override
  State<GenresTab> createState() => _GenresTabState();
}

class _GenresTabState extends State<GenresTab> {
  late final GenreBloc _genreBloc;

  @override
  void initState() {
    super.initState();
    _genreBloc = getIt<GenreBloc>()..add(LoadGenres());
  }

  @override
  void dispose() {
    _genreBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _genreBloc,
      child: BlocConsumer<GenreBloc, GenreState>(
        listener: (context, state) {
          if (state is GenreLoaded && state.message != null) {
            showSuccessSnack(context, state.message!);
          }
          if (state is GenreError) {
            showErrorSnack(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is GenreLoading || state is GenreInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GenreLoaded) {
            return GenreListContent(genres: state.genres);
          }
          if (state is GenreError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GenreBloc>().add(LoadGenres()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class GenreListContent extends StatelessWidget {
  final List<GenreEntity> genres;
  const GenreListContent({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (genres.isEmpty)
          const Center(child: Text('No hay géneros'))
        else
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              return ListTile(
                leading: const Icon(Icons.category),
                title: Text(genre.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditGenreDialog(context, genre),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () => _confirmDeleteGenre(context, genre.id),
                    ),
                  ],
                ),
              );
            },
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddGenreDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showAddGenreDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar género'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del género',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              controller.dispose();
              Navigator.pop(ctx);
              context.read<GenreBloc>().add(
                    CreateGenreEvent(
                      GenreEntity(
                        id: 0,
                        createdAt: DateTime.now(),
                        name: name,
                        description: '',
                      ),
                    ),
                  );
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditGenreDialog(BuildContext context, GenreEntity genre) {
    final controller = TextEditingController(text: genre.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar género'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del género',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              controller.dispose();
              Navigator.pop(ctx);
              context.read<GenreBloc>().add(
                    UpdateGenreEvent(
                      GenreEntity(
                        id: genre.id,
                        createdAt: genre.createdAt,
                        name: name,
                        description: genre.description,
                      ),
                    ),
                  );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGenre(BuildContext context, int genreId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar género'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este género?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<GenreBloc>().add(DeleteGenreEvent(genreId));
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
