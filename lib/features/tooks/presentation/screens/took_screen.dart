import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/chapter_screen.dart';

class TookScreen extends StatefulWidget {
  final TookEntity tooks;

  const TookScreen({super.key, required this.tooks});

  @override
  State<TookScreen> createState() => _TookScreenState();
}

class _TookScreenState extends State<TookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Construye un SliverAppBar que muestra el número del "took" como título.
            SliverAppBar(
              title: Text(widget.tooks.number),
            ),

            // Construye una lista de capítulos utilizando SliverList, donde cada elemento de la lista es un ListTile que muestra el título y número del capítulo. Al hacer clic en un capítulo, se navega a la pantalla de detalles del capítulo correspondiente.
            SliverList.builder(
              itemCount: widget.tooks.listChapter.length,
              itemBuilder: (context, index) {
                var item = widget.tooks.listChapter[index];

                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (_) => getIt<ChapterBloc>(),
                        child: ChapterScreen(
                          i: index,
                          chapters: widget.tooks.listChapter,
                        ),
                      ),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.number),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
