import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';
import 'package:noveles/features/chapters/domain/mark_chapter_as_read.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/widgets/reading_settings_bar.dart';

class ChapterScreen extends StatefulWidget {
  final List<ChapterEntity> chapters;
  final int i;

  const ChapterScreen({
    super.key,
    required this.i,
    required this.chapters,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late final PageController _pageController;
  late final List<ChapterRef> _refs;

  int _currentPageIndex = 0;
  bool _isVisible = true;

  // Per-page scroll controllers keyed by chapterId.
  final Map<int, ScrollController> _scrollControllers = {};

  // Track which chapters have already been marked as read.
  final Set<int> _markedChapters = {};

  // Reading settings state.
  double _fontSize = 14.0;
  ReadingMode _readingMode = ReadingMode.normal;

  // Scroll position persistence debounce.
  Timer? _debounceTimer;

  // Whether SharedPreferences is available (for test environments).
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _refs = widget.chapters.map(ChapterRef.fromEntity).toList();
    _currentPageIndex = widget.i;

    _pageController = PageController(initialPage: widget.i);

    _initPreferences();

    context.read<ChapterBloc>().add(
          LoadChapterByIndex(
            index: widget.i,
            refs: _refs,
          ),
        );
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    for (final ctrl in _scrollControllers.values) {
      ctrl.dispose();
    }
    _scrollControllers.clear();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ─── Scroll controller management ───

  ScrollController _getOrCreateScrollController(int chapterId) {
    return _scrollControllers.putIfAbsent(
      chapterId,
      () {
        final ctrl = ScrollController();
        ctrl.addListener(() => _onScroll(chapterId, ctrl));
        return ctrl;
      },
    );
  }

  // ─── Scroll listener (visibility + mark-as-read) ───

  void _onScroll(int chapterId, ScrollController ctrl) {
    if (!ctrl.hasClients) return;

    final direction = ctrl.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isVisible) {
      setState(() => _isVisible = false);
    } else if (direction == ScrollDirection.forward && !_isVisible) {
      setState(() => _isVisible = true);
    }

    // Mark as read at 80% scroll threshold.
    _checkMarkAsRead(chapterId, ctrl);
  }

  void _checkMarkAsRead(int chapterId, ScrollController ctrl) {
    if (_markedChapters.contains(chapterId)) return;
    if (!ctrl.hasClients) return;

    final maxScroll = ctrl.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final currentScroll = ctrl.offset;
    final ratio = currentScroll / maxScroll;

    if (ratio >= 0.8) {
      _markedChapters.add(chapterId);
      _markChapterAsRead(chapterId);
    }
  }

  void _markChapterAsRead(int chapterId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      getIt<MarkChapterAsRead>()(chapterId, authState.user.id);
    }
  }

  // ─── Scroll position persistence ───

  Future<void> _saveScrollPosition(int chapterId) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      final ctrl = _scrollControllers[chapterId];
      if (ctrl == null || !ctrl.hasClients) return;
      final prefs = _prefs;
      if (prefs == null) return;
      await prefs.setDouble('chapter_scroll_$chapterId', ctrl.offset);
    });
  }

  Future<void> _restoreScrollPosition(int chapterId) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final offset = prefs.getDouble('chapter_scroll_$chapterId');
    if (offset == null || offset <= 0) return;

    // Wait a frame for the scroll controller to be attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = _scrollControllers[chapterId];
      if (ctrl == null || !ctrl.hasClients) return;
      if (ctrl.position.maxScrollExtent >= offset) {
        ctrl.jumpTo(offset);
      }
    });
  }

  // ─── Page change handler ───

  void _onPageChanged(int index) {
    final previousIndex = _currentPageIndex;
    setState(() => _currentPageIndex = index);

    // Save scroll position of the previous page.
    if (previousIndex < _refs.length) {
      final prevId = _refs[previousIndex].id;
      _saveScrollPosition(prevId);
    }

    // Restore scroll position of the new page.
    final currentId = _refs[index].id;
    _restoreScrollPosition(currentId);

    // Dispatch preload for adjacent chapters.
    context.read<ChapterBloc>().add(PreloadAdjacent(
          currentIndex: index,
          refs: _refs,
        ));
  }

  // ─── Background color ───

  Color? _scaffoldBackground(BuildContext context) {
    switch (_readingMode) {
      case ReadingMode.normal:
        return null; // Use theme default.
      case ReadingMode.sepia:
        return const Color(0xFFF5E6D3);
      case ReadingMode.night:
        return const Color(0xFF1A1A2E);
    }
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBackground(context),
      body: BlocListener<ChapterBloc, ChapterState>(
        listener: (context, state) {
          if (state is ChapterLoadError) {
            NotificationService.error(state.message);
          }
        },
        child: BlocBuilder<ChapterBloc, ChapterState>(
          builder: (context, state) {
            if (state is ChapterInitial || state is ChapterLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChapterLoadError) {
              return _buildErrorView(context, state);
            }

            if (state is ChapterPreloading && state is! ChapterSingleLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChapterSingleLoaded) {
              return _buildPageView(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, ChapterLoadError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(state.message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ChapterBloc>().add(
                  LoadChapterByIndex(
                    index: state.index,
                    refs: _refs,
                  ),
                ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(BuildContext context, ChapterSingleLoaded state) {
    return Stack(
      children: [
        // AppBar overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AppBar(
              centerTitle: true,
              title: Text(
                'Capítulo ${_currentPageIndex + 1} de ${state.totalCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Page content
        PageView.builder(
          controller: _pageController,
          itemCount: state.chapterOrder.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final chapterId = state.chapterOrder[index];
            final ch = state.cache[chapterId];
            if (ch == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildChapterPage(context, ch);
          },
        ),

        // Settings bar overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: ReadingSettingsBar(
              fontSize: _fontSize,
              mode: _readingMode,
              onFontSizeChanged: (size) => setState(() => _fontSize = size),
              onModeChanged: (mode) => setState(() => _readingMode = mode),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterPage(BuildContext context, ChapterEntity ch) {
    final scrollCtrl = _getOrCreateScrollController(ch.id);
    final bodyStyle = Theme.of(context).textTheme.bodyLarge;
    final nightMode = _readingMode == ReadingMode.night;
    final textColor =
        nightMode ? Colors.white70 : bodyStyle?.color ?? Colors.black87;

    return CustomScrollView(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Spacer for AppBar
        SliverPadding(padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight)),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chapter title
              Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  ch.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              // Chapter content
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  ch.content,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.6,
                    color: textColor,
                  ),
                ),
              ),
              // Bottom spacer for settings bar
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}
