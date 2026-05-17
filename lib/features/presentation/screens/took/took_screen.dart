import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/presentation/screens/screens.dart';

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
            SliverAppBar(
              title: Text(widget.tooks.number),
            ),
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
