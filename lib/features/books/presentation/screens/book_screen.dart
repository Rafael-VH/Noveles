import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/domain/track_book_view.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_read_chapter_ids.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/chapter_screen.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_app_bar_book.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_detail_content.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_took_list.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';

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

  void _showTookBottomSheet(BuildContext context, TookEntity took) {
    /// Runtime cast: data layer hydrates TookModel with full chapters.
    final chapters = (took is TookModel) ? took.chapters : <ChapterEntity>[];
    if (chapters.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return _TookChapterSheet(
          took: took,
          chapters: chapters,
        );
      },
    );
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
                onTookTap: (took) => _showTookBottomSheet(context, took),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet content for showing chapters of a took.
class _TookChapterSheet extends StatefulWidget {
  final TookEntity took;
  final List<ChapterEntity> chapters;

  const _TookChapterSheet({
    required this.took,
    required this.chapters,
  });

  @override
  State<_TookChapterSheet> createState() => _TookChapterSheetState();
}

class _TookChapterSheetState extends State<_TookChapterSheet> {
  Set<int> _readChapterIds = {};
  bool _loadingReadIds = true;

  @override
  void initState() {
    super.initState();
    _loadReadChapterIds();
  }

  Future<void> _loadReadChapterIds() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final result = await getIt<GetReadChapterIds>()(
        widget.took.id,
        authState.user.id,
      );
      if (!mounted) return;
      switch (result) {
        case Ok(:final value):
          setState(() {
            _readChapterIds = value;
            _loadingReadIds = false;
          });
        case Err():
          setState(() => _loadingReadIds = false);
      }
    } else {
      if (!mounted) return;
      setState(() => _loadingReadIds = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    widget.took.number,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.took.title.isNotEmpty)
                    Expanded(
                      child: Text(
                        widget.took.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Chapter list or loading
            Expanded(
              child: _loadingReadIds
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: widget.chapters.length,
                      itemBuilder: (context, index) {
                        final item = widget.chapters[index];
                        return ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (_) => getIt<ChapterBloc>(),
                                  child: ChapterScreen(
                                    i: index,
                                    chapters: widget.chapters,
                                  ),
                                ),
                              ),
                            );
                          },
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: _readChapterIds.contains(item.id)
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                          subtitle: Text(item.number),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
