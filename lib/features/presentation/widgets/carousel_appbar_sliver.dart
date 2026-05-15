import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/screens/screens.dart';

SliverAppBar sliverAppBarV1Home({
  required BuildContext context,
  required List<BookEntity> listBook,
  required List<Widget> actions,
}) {
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
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => BookScreen(books: item),
              transitionDuration: const Duration(seconds: 1),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    item.cover,
                  ),
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
                        Theme.of(context).colorScheme.surface.withOpacity(0.9),
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
                            ?.copyWith(color: Colors.grey),
                      ),
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
