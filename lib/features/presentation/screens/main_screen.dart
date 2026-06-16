import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/genres/domain/genre_entity.dart';
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
  late final BookBloc _bookBloc;
  late final GenreBloc _genreBloc;

  @override
  void initState() {
    super.initState();
    _bookBloc = BookBloc(
      getBooks: getIt(),
      getBookById: getIt(),
      onlyVisible: true,
    )..add(LoadBooks());
    _genreBloc = getIt<GenreBloc>()..add(LoadGenres());
  }

  @override
  void dispose() {
    _bookBloc.close();
    _genreBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bookBloc),
        BlocProvider.value(value: _genreBloc),
      ],
      child: Scaffold(
        drawer: const AppDrawer(),
        body: BlocBuilder<BookBloc, BookState>(
          builder: (context, bookState) {
            return BlocBuilder<GenreBloc, GenreState>(
              builder: (context, genreState) {
                // Manejo de estados: muestra un indicador de carga, mensajes de error o el contenido principal según el estado actual de los blocs.
                if (bookState is BookLoading || genreState is GenreLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Manejo de errores: muestra un mensaje de error y un botón para reintentar la carga de datos si ocurre un error en cualquiera de los blocs.
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

                // Manejo de errores: muestra un mensaje de error y un botón para reintentar la carga de datos si ocurre un error en cualquiera de los blocs.
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

                // Si ambos blocs han cargado correctamente, se construye el contenido principal de la pantalla utilizando los datos de libros y géneros.
                if (bookState is BookLoaded && genreState is GenreLoaded) {
                  final listBook = bookState.books;
                  final listGenre = genreState.genres;
                  return _buildContent(context, listBook, listGenre);
                }

                // Estado por defecto: muestra un indicador de carga mientras se espera la carga de datos.
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  // Construye el contenido principal de la pantalla, incluyendo el carrusel de libros y la lista de géneros.
  Widget _buildContent(
    BuildContext context,
    List<BookEntity> listBook,
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
