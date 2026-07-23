import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';

class AppDrawerHeader extends StatelessWidget {
  final UserEntity? user;

  const AppDrawerHeader({super.key, this.user});

  const AppDrawerHeader.simplified({super.key}) : user = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            cs.primaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: user != null ? _authenticatedContent(context, user!) : _simplifiedContent(context),
    );
  }

  Widget _authenticatedContent(BuildContext context, UserEntity user) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: (user.avatarUrl?.isNotEmpty ?? false)
              ? NetworkImage(getIt<CoverUrlService>()(user.avatarUrl!))
              : null,
          child: (user.avatarUrl?.isEmpty ?? true)
              ? Icon(Icons.person, size: 28, color: cs.onPrimary)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? user.email,
          style: theme.textTheme.titleLarge?.copyWith(color: cs.onPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (user.displayName != null) ...[
          const SizedBox(height: 2),
          Text(
            user.email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _simplifiedContent(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.auto_stories, size: 40, color: cs.onPrimary),
        const SizedBox(height: 16),
        Text(
          'Noveles',
          style: theme.textTheme.titleLarge?.copyWith(color: cs.onPrimary),
        ),
        const SizedBox(height: 2),
        Text(
          'Iniciá sesión para continuar',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
