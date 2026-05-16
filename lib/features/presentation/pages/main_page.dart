import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/screens.dart';
import 'package:noveles/features/presentation/widgets/carousel_appbar_sliver.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
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
          SliverAppBarV1Home(
            listBook: listBook,
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              Switch(
                value: context.read<ThemeBloc>().state.themeData.brightness ==
                    Brightness.dark,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ThemeChanged(value));
                },
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
