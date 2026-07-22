import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/app/presentation/bloc/popular_views/popular_views_bloc.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_vertical.dart';
import 'package:noveles/features/app/presentation/widgets/section_header.dart';
import 'package:noveles/features/books/presentation/screens/book_screen.dart';

class SectionMasVistos extends StatefulWidget {
  const SectionMasVistos({super.key});

  @override
  State<SectionMasVistos> createState() => _SectionMasVistosState();
}

class _SectionMasVistosState extends State<SectionMasVistos> {
  @override
  void initState() {
    super.initState();
    context.read<PopularViewsBloc>().add(const LoadPopularViews());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PopularViewsBloc, PopularViewsState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is PopularViewsLoaded) {
          return Column(
            children: [
              const SectionHeader(title: 'Más vistos', icon: Icons.visibility),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.books.length,
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: BookCardVertical(
                        book: book,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookScreen(book: book),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
