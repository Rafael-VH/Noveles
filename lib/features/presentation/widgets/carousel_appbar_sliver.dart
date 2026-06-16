import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/books/domain/book_entity.dart';
import 'package:noveles/features/presentation/widgets/label_badge.dart';

class SliverAppBarHome extends StatelessWidget {
  final List<BookEntity> listBook;
  final List<Widget> actions;
  final void Function(BookEntity book) onBookTap;

  const SliverAppBarHome({
    super.key,
    required this.listBook,
    required this.actions,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240.0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: actions,
      flexibleSpace: CarouselSlider.builder(
        itemCount: listBook.length,
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 1.0,
          height: 240.0,
          initialPage: 0,
          viewportFraction: 1.0,
        ),
        itemBuilder: (context, index, realIndex) {
          var item = listBook[index];

          return InkWell(
            onTap: () => onBookTap(item),
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
    );
  }
}
