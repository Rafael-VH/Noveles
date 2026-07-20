import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/shared/presentation/widgets/empty_state.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/presentation/bloc/book_bloc.dart';
import 'package:noveles/features/genres/presentation/bloc/genre_bloc.dart';
import 'package:noveles/features/books/presentation/screens/book_screen.dart';
import 'package:noveles/features/genres/presentation/screens/genre_screen.dart';
import 'package:noveles/features/app/presentation/widgets/app_drawer.dart';
import 'package:noveles/features/app/presentation/widgets/carousel_appbar_sliver.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final bookState = context.read<BookBloc>().state;
      if (bookState is BookLoaded && bookState.hasMore) {
        _currentPage++;
        context.read<BookBloc>().add(LoadMoreBooks(_currentPage));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => BookBloc(
            getBooks: getIt(),
            getBookById: getIt(),
            onlyVisible: true,
          )..add(LoadBooks()),
        ),
        BlocProvider(
          create: (_) => getIt<GenreBloc>()..add(LoadGenres()),
        ),
      ],
      child: Scaffold(
        drawer: Builder(
          builder: (context) {
            final authState = context.read<AuthBloc>().state;
            final user = authState is AuthAuthenticated ? authState.user : null;
            return AppDrawer(
              isScan: user?.isScan ?? false,
              isAdmin: user?.isAdmin ?? false,
            );
          },
        ),
        body: BlocBuilder<BookBloc, BookState>(
          builder: (context, bookState) {
            return BlocBuilder<GenreBloc, GenreState>(
              builder: (context, genreState) {
                if (bookState is BookLoading || genreState is GenreLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bookState is BookError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${bookState.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<BookBloc>().add(LoadBooks()),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (genreState is GenreError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${genreState.message}'),
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

                if (bookState is BookLoaded && genreState is GenreLoaded) {
                  final listBook = bookState.books;
                  final listGenre = genreState.genres;
                  return _buildContent(
                    context,
                    listBook,
                    listGenre,
                    hasMore: bookState.hasMore,
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<BookWithRelations> listBook,
    List<GenreEntity> listGenre, {
    bool hasMore = false,
  }) {
    if (listBook.isEmpty) {
      return SafeArea(
        child: Column(
          children: [
            AppBar(
              title: const Text('Noveles'),
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
            const Expanded(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                message: 'No hay libros disponibles',
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Carousel
          SliverAppBarHome(
            listBook: listBook,
            onBookTap: (book) => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => BookScreen(book: book),
                transitionDuration: const Duration(seconds: 1),
              ),
            ),
            actions: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32.0)),

          // Géneros
          SliverToBoxAdapter(
            child: SizedBox(
              height: 60.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: listGenre
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GenreScreen(
                                  genre: item.name,
                                  books: listBook,
                                  coverUrlService: getIt<CoverUrlService>(),
                                ),
                              ),
                            );
                          },
                          child: Chip(
                            label: Text(item.name),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          if (hasMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
