import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:noveles/features/books/domain/book_with_relations.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_app_bar_book.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_persistent_header_book.dart';
import 'package:noveles/features/presentation/screens/screens.dart';
import 'package:noveles/features/presentation/views/views.dart';

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
              DetailView(books: widget.book),
              TookView(
                tooks: widget.book.listTook,
                onTookTap: (took) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TookScreen(tooks: took),
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
