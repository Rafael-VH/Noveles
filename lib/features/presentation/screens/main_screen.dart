import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/screens.dart';
import 'package:noveles/features/presentation/widgets/app_drawer.dart';
import 'package:noveles/features/presentation/widgets/carousel_appbar_sliver.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookBloc(
        getBooks: getIt(),
        getBookById: getIt(),
        onlyVisible: true,
      )..add(LoadBooks()),
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
                return Center(child: Text('Error: ${bookState.message}'));
              }
              if (genreState is GenreError) {
                return Center(child: Text('Error: ${genreState.message}'));
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
    List<BookEntity> listBook,
    List<GenreEntity> listGenre,
  ) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBarHome(
            listBook: listBook,
            onBookTap: (book) => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => BookScreen(books: book),
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
