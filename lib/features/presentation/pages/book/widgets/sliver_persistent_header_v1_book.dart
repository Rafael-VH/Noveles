import 'package:flutter/material.dart';
import 'package:noveles/features/presentation/delegates/delegate.dart';

class SliverPersistentHeaderV1Book extends StatelessWidget {
  const SliverPersistentHeaderV1Book({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  final TabController tabController;
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: SliverAppBarDelegate(
        TabBar(
          controller: tabController,
          tabs: tabs,
          physics: const BouncingScrollPhysics(),
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      pinned: true,
    );
  }
}
