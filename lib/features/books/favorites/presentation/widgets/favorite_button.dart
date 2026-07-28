import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/books/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/shared/presentation/widgets/snackbar_helper.dart';

class FavoriteButton extends StatefulWidget {
  final int bookId;
  final bool initialIsFavorite;

  const FavoriteButton({
    super.key,
    required this.bookId,
    this.initialIsFavorite = false,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoriteBloc>().add(
            CheckFavoriteStatus(
              userId: authState.user.id,
              bookId: widget.bookId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state is FavoriteStatusChecked) {
          setState(() {
            _isFavorite = state.isFavorite;
          });
        } else if (state is FavoriteToggled) {
          setState(() {
            _isFavorite = state.isFavorite;
          });
        } else if (state is FavoriteError) {
          showErrorSnack(context, state.message);
        }
      },
      child: IconButton(
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Theme.of(context).colorScheme.error : null,
        ),
        onPressed: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<FavoriteBloc>().add(
                  ToggleFavoriteEvent(
                    userId: authState.user.id,
                    bookId: widget.bookId,
                  ),
                );
          }
        },
      ),
    );
  }
}
