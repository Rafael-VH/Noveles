import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/helpers/text_stats.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';

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
  int caracteres = 0;
  int palabras = 0;
  int frases = 0;
  int parrafos = 0;
  bool isVisible = true;
  double textSize = 14.0;
  String selectedFont = 'Arial';
  FontStyle selectedStyle = FontStyle.normal;
  FontWeight selectedWeight = FontWeight.normal;
  ScrollController scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    textEditingController.text = textSize.toString();
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
            chapters: widget.chapters,
          ),
        );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChapterBloc, ChapterState>(
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
                        chapters: widget.chapters,
                      ),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is ChapterLoaded) {
            return SafeArea(
              child: PageView.builder(
                itemCount: state.chapters.length,
                physics: const BouncingScrollPhysics(),
                controller: PageController(initialPage: state.initialIndex),
                onPageChanged: (int index) => setState(() {
                  currentPageIndex = index;
                }),
                itemBuilder: (context, index) {
                  final ch = state.chapters[index];
                  caracteres = TextStats.characters(ch.content);
                  palabras = TextStats.words(ch.content);
                  frases = TextStats.sentences(ch.content);
                  parrafos = TextStats.paragraphs(ch.content);

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
                                style: TextStyle(
                                  fontFamily: selectedFont,
                                  fontSize: textSize,
                                  fontWeight: selectedWeight,
                                  fontStyle: selectedStyle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
