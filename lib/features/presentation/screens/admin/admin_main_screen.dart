import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/supabase/storage_helper.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/widgets/app_drawer.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

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
          builder: (context, state) {
            if (state is AdminLoading || state is AdminInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminLoaded) {
              return _buildContent(context, state);
            }
            if (state is AdminError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AdminBloc>()
                          .add(const LoadAdminBooks()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminLoaded state) {
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
                                book.isVisible ? Icons.check_circle : Icons.cancel,
                                size: 16,
                                color: book.isVisible ? Colors.green : Colors.red,
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
                          trailing: IconButton(
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
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
