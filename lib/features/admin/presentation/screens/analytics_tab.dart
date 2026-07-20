import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_state.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<AdminAnalyticsBloc>()
        ..add(const LoadAnalytics()),
      child: const _AnalyticsTabContent(),
    );
  }
}

class _AnalyticsTabContent extends StatelessWidget {
  const _AnalyticsTabContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AnalyticsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context
                          .read<AdminAnalyticsBloc>()
                          .add(const LoadAnalytics());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AnalyticsLoaded) {
          return _buildLoaded(context, state);
        }

        return const Center(child: Text('Presiona para cargar datos'));
      },
    );
  }

  Widget _buildLoaded(BuildContext context, AnalyticsLoaded state) {
    final overview = state.overview;
    final totalViews = overview['total_views'] ?? 0;
    final viewsToday = overview['views_today'] ?? 0;
    final totalBooks = overview['total_books'] ?? 0;
    final visibleBooks = overview['visible_books'] ?? 0;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminAnalyticsBloc>().add(const LoadAnalytics());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview metrics
          Text(
            'Resumen',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildMetricsGrid(
            context,
            totalViews: totalViews,
            viewsToday: viewsToday,
            totalBooks: totalBooks,
            visibleBooks: visibleBooks,
          ),
          const SizedBox(height: 24),

          // Top books
          Text(
            'Libros más vistos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (state.topBooks.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Sin datos todavía',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            )
          else
            ...state.topBooks.asMap().entries.map(
                  (entry) => _buildTopBookCard(context, entry.key, entry.value),
                ),

          const SizedBox(height: 24),

          // Views trend
          Text(
            'Tendencia de vistas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (state.trend.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Sin datos todavía',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: state.trend.map((entry) {
                    final date = entry['view_date']?.toString() ?? '';
                    final count = entry['view_count'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(date),
                          ),
                          Text(
                            '$count vistas',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context, {
    required int totalViews,
    required int viewsToday,
    required int totalBooks,
    required int visibleBooks,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _MetricCard(
          icon: Icons.visibility,
          label: 'Vistas totales',
          value: '$totalViews',
          color: Theme.of(context).colorScheme.primary,
        ),
        _MetricCard(
          icon: Icons.today,
          label: 'Vistas hoy',
          value: '$viewsToday',
          color: Theme.of(context).colorScheme.tertiary,
        ),
        _MetricCard(
          icon: Icons.library_books,
          label: 'Libros totales',
          value: '$totalBooks',
          color: Theme.of(context).colorScheme.secondary,
        ),
        _MetricCard(
          icon: Icons.check_circle_outline,
          label: 'Libros visibles',
          value: '$visibleBooks',
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildTopBookCard(BuildContext context, int index, dynamic book) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
        ),
        title: Text(
          book['book_name']?.toString() ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          '${book['view_count'] ?? 0} vistas',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
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
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
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
