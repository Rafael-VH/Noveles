import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/data/local/data_sources/data_source.dart';
import 'package:noveles/features/data/local/models/model.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/screens.dart';
import 'package:noveles/features/presentation/widgets/carousel_appbar_sliver.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<GenreLocalModel> listGenre = GenreLocalDataSource.allGenre;
  late List<BookLocalModel> listBook = BookLocalDataSource.allBook;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          //
          sliverAppBarV1Home(
            context: context,
            listBook: listBook,
            actions: [
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
              height: 60.0, // Ajusta la altura según sea necesario
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: listGenre
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            // Navegar a la pantalla de género
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
                            label: Text(
                              item.name,
                            ),
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
