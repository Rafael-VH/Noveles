import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/shared/domain/entities/book_with_relations.dart';
import 'package:noveles/core/presentation/widgets/label_badge.dart';

class SliverAppBarHome extends StatefulWidget {
  final List<BookWithRelations> listBook;
  final List<Widget> actions;
  final void Function(BookWithRelations book) onBookTap;

  const SliverAppBarHome({
    super.key,
    required this.listBook,
    required this.actions,
    required this.onBookTap,
  });

  @override
  State<SliverAppBarHome> createState() => _SliverAppBarHomeState();
}

class _SliverAppBarHomeState extends State<SliverAppBarHome> {
  int _carouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    final responsiveHeight =
        (MediaQuery.of(context).size.height * 0.35).clamp(200.0, 300.0);

    return SliverAppBar(
      expandedHeight: responsiveHeight,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: widget.actions,
      flexibleSpace: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: widget.listBook.length,
            options: CarouselOptions(
              autoPlay: true,
              aspectRatio: 1.0,
              height: responsiveHeight,
              initialPage: 0,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) =>
                  setState(() => _carouselIndex = index),
            ),
            itemBuilder: (context, index, realIndex) {
              var item = widget.listBook[index];

              return InkWell(
                onTap: () => widget.onBookTap(item),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: getIt<CoverUrlService>()(item.cover),
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: AlignmentDirectional.topCenter,
                            end: AlignmentDirectional.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.9),
                              Theme.of(context).colorScheme.surface,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              item.name,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              "Autor ${item.author}",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                            ),
                            if (item.listLabel.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: item.listLabel
                                    .map((l) => LabelBadge(
                                          name: l.name,
                                          color: l.color,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.listBook.isNotEmpty)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.listBook.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: _carouselIndex == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _carouselIndex == i
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
