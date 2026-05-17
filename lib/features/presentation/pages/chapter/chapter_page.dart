import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:noveles/features/domain/entities/entities.dart';

class ChapterPage extends StatefulWidget {
  final int i;
  final List<ChapterEntity> chapters;

  const ChapterPage({
    super.key,
    required this.i,
    required this.chapters,
  });

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
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
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  int countCaracteres(String? texto) {
    if (texto == null || texto.isEmpty) {
      return 0;
    }
    final textoLimpio = texto.replaceAll(RegExp(r'([.,!?; ])'), '');
    return textoLimpio.length;
  }

  int countPalabras(String? texto) {
    if (texto == null || texto.isEmpty) {
      return 0;
    }
    List<String> palabras = texto.split(RegExp(r'\s+'));
    return palabras.length;
  }

  int countFrases(String? texto) {
    if (texto == null || texto.isEmpty) {
      return 0;
    }
    List<String> frases = texto.split(RegExp(r'[.!?]'));
    return frases.length;
  }

  int countParrafos(String? texto) {
    if (texto == null || texto.isEmpty) {
      return 0;
    }
    List<String> parrafos = texto.split(RegExp(r'\n\s*\n'));
    return parrafos.length;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView.builder(
        itemCount: widget.chapters.length,
        physics: const BouncingScrollPhysics(),
        controller: PageController(initialPage: widget.i),
        onPageChanged: (int index) => setState(() {
          currentPageIndex = index;
        }),
        itemBuilder: (context, index) {
          final ch = widget.chapters[index];
          caracteres = countCaracteres(ch.content);
          palabras = countPalabras(ch.content);
          frases = countFrases(ch.content);
          parrafos = countParrafos(ch.content);

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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}
