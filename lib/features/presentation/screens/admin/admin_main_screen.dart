import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/supabase/storage_helper.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/screens.dart';
import 'package:noveles/features/presentation/widgets/app_drawer.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminBloc>()..add(const LoadAdminBooks()),
      child: Scaffold(
        drawer: const AppDrawer(isAdmin: true),
        appBar: AppBar(title: const Text('Panel Admin')),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            }
            if (state is AdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) => IndexedStack(
            index: _currentIndex,
            children: [
              _BooksTab(state: state),
              const _GenresTab(),
              const _UsersTab(),
              const _AnalyticsTab(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: 'Libros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Géneros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Usuarios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analíticas',
            ),
          ],
        ),
      ),
    );
  }
}

class _BooksTab extends StatelessWidget {
  final AdminState state;
  const _BooksTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is AdminLoading || state is AdminInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AdminLoaded) {
      return _BooksContent(state: state as AdminLoaded);
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

class _BooksContent extends StatelessWidget {
  final AdminLoaded state;
  const _BooksContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.books.length;
    final visible = state.books.where((b) => b.isVisible).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LabelManagementScreen()),
            ),
            icon: const Icon(Icons.label),
            label: const Text('Gestionar Etiquetas'),
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
            child: state.books.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(
                        height: 200,
                        child: Center(child: Text('No hay libros')),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: state.books.length,
                    itemBuilder: (context, index) {
                      final book = state.books[index];
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
                                color:
                                    book.isVisible ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                book.isVisible ? 'Visible' : 'Oculto',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: book.isVisible
                                      ? Colors.green
                                      : Colors.red,
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: const Text('¿Estás seguro de que deseas eliminar este libro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(DeleteAdminBook(bookId));
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenresTab extends StatefulWidget {
  const _GenresTab();

  @override
  State<_GenresTab> createState() => _GenresTabState();
}

class _GenresTabState extends State<_GenresTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<GenreBloc>()..add(LoadGenres()),
      child: BlocConsumer<GenreBloc, GenreState>(
        listener: (context, state) {
          if (state is GenreLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            );
          }
          if (state is GenreError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GenreLoading || state is GenreInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GenreLoaded) {
            return _GenreListContent(genres: state.genres);
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

class _GenreListContent extends StatelessWidget {
  final List<GenreEntity> genres;
  const _GenreListContent({required this.genres});

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
                      icon: const Icon(Icons.delete, color: Colors.red),
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
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminUsersBloc>()..add(const LoadAdminUsers()),
      child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
        builder: (context, state) {
          if (state is AdminUsersLoading || state is AdminUsersInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminUsersLoaded) {
            final users = state.users;
            if (users.isEmpty) {
              return const Center(child: Text('No hay usuarios'));
            }
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.role == 'admin'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondaryContainer,
                    child: Text(
                      (user.displayName ?? user.email)[0].toUpperCase(),
                    ),
                  ),
                  title: Text(user.displayName ?? user.email),
                  subtitle: Text(user.email),
                  trailing: _RoleBadge(role: user.role),
                );
              },
            );
          }
          if (state is AdminUsersError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AdminUsersBloc>()
                        .add(const LoadAdminUsers()),
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

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'Admin' : role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isAdmin
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Analíticas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Próximamente',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
