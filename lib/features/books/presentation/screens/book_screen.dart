import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:noveles/features/books/domain/track_book_view.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_app_bar_book.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_persistent_header_book.dart';
import 'package:noveles/features/tooks/presentation/screens/took_screen.dart';
import 'package:noveles/features/books/presentation/views/detail/detail_view.dart';
import 'package:flutter/widgets.dart';
import 'package:noveles/features/tooks/presentation/views/took_view.dart';

class BookScreen extends StatefulWidget {
  final BookWithRelations book;

  const BookScreen({super.key, required this.book});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool isVisible = true;
  List<Widget> nameTab = [const Tab(text: 'Info'), const Tab(text: 'Took')];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          isVisible = false;
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          isVisible = true;
        }
      });
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        GetIt.instance<TrackBookView>()(widget.book.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBarBook(books: widget.book),
              SliverPersistentHeaderBook(
                tabController: _tabController,
                tabs: nameTab,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              PrimaryScrollController.none(
                child: DetailView(books: widget.book),
              ),
              PrimaryScrollController.none(
                child: TookView(
                  tooks: widget.book.listTook,
                  onTookTap: (took) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TookScreen(tooks: took),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
