import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/domain/track_book_view.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_action_bar.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_metadata_grid.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_quick_stats_bar.dart';
import 'package:noveles/features/books/presentation/screens/widgets/sliver_app_bar_book.dart';
import 'package:noveles/features/books/presentation/screens/widgets/book_took_list.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_read_chapter_ids.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/chapter_screen.dart';
import 'package:noveles/features/app/presentation/widgets/genre_chip_styled.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/features/tooks/data/took_model.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class BookScreen extends StatefulWidget {
  final BookWithRelations book;

  const BookScreen({super.key, required this.book});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        GetIt.instance<TrackBookView>()(widget.book.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _startFirstChapter(BuildContext context) {
    if (widget.book.listTook.isEmpty) return;
    final firstTook = widget.book.listTook.first;
    final chapters = (firstTook is TookModel) ? firstTook.chapters : <ChapterEntity>[];
    if (chapters.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => getIt<ChapterBloc>(),
          child: ChapterScreen(
            i: 0,
            chapters: chapters,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final book = widget.book;

    return BlocProvider<FavoriteBloc>(
      create: (_) => getIt<FavoriteBloc>(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ── Hero app bar with cover ─────────────────────
            SliverAppBarBook(books: book),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Quick Stats Bar ──────────────────────────────
            SliverToBoxAdapter(
              child: BookQuickStatsBar(book: book),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Main Action Bar (Read / Favorite) ────────────
            SliverToBoxAdapter(
              child: BookActionBar(
                bookId: book.id,
                initialIsFavorite: book.isFavorite,
                onReadTap: () => _startFirstChapter(context),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Persistent Tab Bar Header ────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Información'),
                    Tab(text: 'Tomos y Capítulos'),
                  ],
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                colorScheme.surface,
              ),
            ),

            // ── Tab Content ──────────────────────────────────
            if (_tabController.index == 0) ...[
              // ── Description Card ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sinopsis',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        book.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Modular Metadata Grid ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Detalles',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      BookMetadataGrid(
                        items: [
                          MetadataItemData(
                            title: 'Publicado',
                            value: book.release,
                            icon: Icons.calendar_today_rounded,
                            accentColor: colorScheme.primary,
                          ),
                          MetadataItemData(
                            title: 'Tipo Novela',
                            value: book.type,
                            icon: Icons.bookmark_border_rounded,
                            accentColor: colorScheme.tertiary,
                          ),
                          MetadataItemData(
                            title: 'País',
                            value: book.country,
                            icon: Icons.public_rounded,
                            accentColor: colorScheme.secondary,
                          ),
                          MetadataItemData(
                            title: 'Estado',
                            value: book.state,
                            icon: Icons.swap_horizontal_circle_outlined,
                            accentColor: colorScheme.error,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Genres Section ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'Géneros',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: book.listGenre
                        .map((g) => GenreChipStyled(
                              genre: g,
                              onTap: () {},
                            ))
                        .toList(),
                  ),
                ),
              ),

              // ── Source Section (conditional) ───────────────
              if (book.source.isNotEmpty || book.link.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuente',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (book.source.isNotEmpty)
                          _SourceRow(
                            label: 'Nombre',
                            value: book.source,
                          ),
                        if (book.link.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _SourceRow(
                            label: 'Enlace',
                            value: book.link,
                            isLink: true,
                            onTap: () async {
                              final uri = Uri.parse(book.link);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ] else ...[
              // ── Volumes / Took List Tab ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: BookTookList(
                    tooks: book.listTook,
                    onTookTap: (took) => _showTookBottomSheet(context, took),
                  ),
                ),
              ),
            ],

            // ── Bottom Padding ───────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }
}

/// Persistent Header Delegate for TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

/// Source label + value row with optional link tap.
class _SourceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;

  const _SourceRow({
    required this.label,
    required this.value,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: isLink
              ? GestureDetector(
                  onTap: onTap,
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: colorScheme.primary,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
        ),
      ],
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withAlpha(80),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
