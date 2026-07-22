import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/chapter_ref.dart';
import 'package:noveles/features/chapters/domain/mark_chapter_as_read.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';

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
  int currentPageIndex = 0;
  bool isVisible = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    _markCurrentChapterAsRead();
    scrollController.addListener(() {
      setState(() {
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          isVisible = false;
        } else if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          isVisible = true;
        }
      });
    });
    context.read<ChapterBloc>().add(
          LoadChapterContent(
            initialIndex: widget.i,
            chapters: widget.chapters.map(ChapterRef.fromEntity).toList(),
          ),
        );
  }

  void _markCurrentChapterAsRead() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      getIt<MarkChapterAsRead>()(widget.chapters[widget.i].id, authState.user.id);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ChapterBloc, ChapterState>(
        listener: (context, state) {
          if (state is ChapterError) {
            NotificationService.error(state.message);
          }
        },
        child: BlocBuilder<ChapterBloc, ChapterState>(
          builder: (context, state) {
            if (state is ChapterLoading || state is ChapterInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChapterError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ChapterBloc>().add(
                            LoadChapterContent(
                              initialIndex: widget.i,
                              chapters: widget.chapters
                                  .map(ChapterRef.fromEntity)
                                  .toList(),
                            ),
                          ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (state is ChapterLoaded) {
              return PageView.builder(
                itemCount: state.chapters.length,
                physics: const BouncingScrollPhysics(),
                controller: PageController(initialPage: state.initialIndex),
                onPageChanged: (int index) => setState(() {
                  currentPageIndex = index;
                }),
                itemBuilder: (context, index) {
                  final ch = state.chapters[index];

                  return CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        floating: false,
                        centerTitle: true,
                        title: Text(
                          ch.number,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                ch.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                ch.content,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
