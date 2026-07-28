import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_read_chapter_ids.dart';
import 'package:noveles/features/chapters/presentation/bloc/chapter_bloc.dart';
import 'package:noveles/features/chapters/presentation/screens/chapter_screen.dart';
import 'package:noveles/features/tooks/domain/took_entity.dart';
import 'package:noveles/features/tooks/presentation/screens/widgets/took_sliver_header.dart';

class TookScreen extends StatefulWidget {
  final TookEntity tooks;

  const TookScreen({super.key, required this.tooks});

  @override
  State<TookScreen> createState() => _TookScreenState();
}

class _TookScreenState extends State<TookScreen> {
  List<ChapterEntity> get _chapters => widget.tooks.chapters;

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
        widget.tooks.id,
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
          setState(() {
            _loadingReadIds = false;
          });
      }
    } else {
      setState(() {
        _loadingReadIds = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            TookSliverHeader(tooks: widget.tooks),

            if (_loadingReadIds)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverList.builder(
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final item = chapters[index];

                  return ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => getIt<ChapterBloc>(),
                          child: ChapterScreen(
                            i: index,
                            chapters: chapters,
                          ),
                        ),
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }
}
