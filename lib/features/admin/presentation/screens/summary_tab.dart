import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_state.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminAnalyticsBloc>().add(const LoadAnalytics());
        context.read<AdminUsersBloc>().add(const LoadAdminUsers());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _WelcomeCard(),
          SizedBox(height: 20),
          _MetricsGrid(),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final email =
        authState is AuthAuthenticated ? authState.user.email : 'Admin';
    final displayName =
        authState is AuthAuthenticated ? authState.user.displayName : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                (displayName ?? email)[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel de Administración',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    final analyticsState = context.watch<AdminAnalyticsBloc>().state;
    final usersState = context.watch<AdminUsersBloc>().state;

    if (analyticsState is AnalyticsLoading &&
        analyticsState is! AnalyticsLoaded) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    int totalBooks = 0;
    int visibleBooks = 0;
    int totalViews = 0;
    int viewsToday = 0;

    if (analyticsState is AnalyticsLoaded) {
      totalViews = (analyticsState.overview['total_views'] ?? 0) as int;
      viewsToday = (analyticsState.overview['views_today'] ?? 0) as int;
      totalBooks = (analyticsState.overview['total_books'] ?? 0) as int;
      visibleBooks = (analyticsState.overview['visible_books'] ?? 0) as int;
    }

    int totalUsers = 0;
    if (usersState is AdminUsersLoaded) {
      totalUsers = usersState.users.length;
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _SummaryMetric(
          icon: Icons.library_books,
          label: 'Libros',
          value: '$totalBooks',
          color: Theme.of(context).colorScheme.secondary,
        ),
        _SummaryMetric(
          icon: Icons.check_circle_outline,
          label: 'Visibles',
          value: '$visibleBooks',
          color: Colors.green.shade600,
        ),
        _SummaryMetric(
          icon: Icons.visibility,
          label: 'Vistas totales',
          value: '$totalViews',
          color: Theme.of(context).colorScheme.primary,
        ),
        _SummaryMetric(
          icon: Icons.today,
          label: 'Vistas hoy',
          value: '$viewsToday',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        _SummaryMetric(
          icon: Icons.people,
          label: 'Usuarios',
          value: '$totalUsers',
          color: Colors.orange.shade600,
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
