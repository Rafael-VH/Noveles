import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/app/presentation/bloc/recent_views/recent_views_bloc.dart';
import 'package:noveles/features/app/presentation/widgets/book_card_vertical.dart';
import 'package:noveles/features/app/presentation/widgets/section_title.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/presentation/screens/book_screen.dart';
import 'package:noveles/shared/presentation/widgets/snackbar_helper.dart';

class SectionRecentViews extends StatefulWidget {
  const SectionRecentViews({super.key});

  @override
  State<SectionRecentViews> createState() => _SectionRecentViewsState();
}

class _SectionRecentViewsState extends State<SectionRecentViews> {
  @override
  void initState() {
    super.initState();
    _loadRecentViews();
  }

  void _loadRecentViews() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RecentViewsBloc>().add(LoadRecentViews(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecentViewsBloc, RecentViewsState>(
      listener: (context, state) {
        if (state is RecentViewsError) {
          showErrorSnack(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is RecentViewsLoaded) {
          return Column(
            children: [
              const SectionTitle(title: 'Continuar leyendo', icon: Icons.history),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.books.length,
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: BookCardVertical(
                        book: book,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookScreen(book: book),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
