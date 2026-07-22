import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/books/domain/track_book_view.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_app_bar_book.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_detail_content.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_took_list.dart';
import 'package:noveles/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/features/tooks/presentation/screens/took_screen.dart';

class BookScreen extends StatefulWidget {
  final BookWithRelations book;

  const BookScreen({super.key, required this.book});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        GetIt.instance<TrackBookView>()(widget.book.id);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoriteBloc>(
      create: (_) => getIt<FavoriteBloc>(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBarBook(books: widget.book),
            SliverToBoxAdapter(
              child: BookDetailContent(books: widget.book),
            ),
            SliverToBoxAdapter(
              child: BookTookList(
                tooks: widget.book.listTook,
                onTookTap: (took) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => TookScreen(tooks: took),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
