import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/pages/book/widgets/sliver_app_bar_v1_book.dart';
import 'package:noveles/features/presentation/pages/book/widgets/sliver_persistent_header_v1_book.dart';
import 'package:noveles/features/presentation/screens/screens.dart';
import 'package:noveles/features/presentation/views/views.dart';

class BookScreen extends StatefulWidget {
  final BookEntity books;

  const BookScreen({super.key, required this.books});

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

  void showInfoDialog() {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: true,
      useRootNavigator: true,
      barrierColor:
          Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
      builder: (context) => AlertDialog(
        scrollable: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          ElevatedButton(
            onPressed: () {},
            child: const Text("Aceptar"),
          ),
        ],
        title: const Center(
          child: Text('Información'),
        ),
        content: const Column(
          children: [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBarV1Book(
                books: widget.books,
                infoIcon: IconButton(
                  onPressed: () => showInfoDialog(),
                  icon: const Icon(Icons.info_outlined),
                ),
              ),
              SliverPersistentHeaderV1Book(
                tabController: _tabController,
                tabs: nameTab,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              DetailView(books: widget.books),
              TookView(
                tooks: widget.books.listTook,
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
