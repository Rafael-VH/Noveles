import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/books/domain/book_with_relations.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
import 'package:noveles/features/books/presentation/bloc/book_bloc.dart';
import 'package:noveles/features/genres/presentation/bloc/genre_bloc.dart';
import 'package:noveles/features/books/presentation/screens/book_screen.dart';
import 'package:noveles/features/genres/presentation/screens/genre_screen.dart';
import 'package:noveles/core/presentation/widgets/app_drawer.dart';
import 'package:noveles/core/presentation/widgets/carousel_appbar_sliver.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
        drawer: const AppDrawer(),
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
                  return _buildContent(context, listBook, listGenre);
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
    List<GenreEntity> listGenre,
  ) {
    return SafeArea(
      child: CustomScrollView(
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
        ],
      ),
    );
  }
}
