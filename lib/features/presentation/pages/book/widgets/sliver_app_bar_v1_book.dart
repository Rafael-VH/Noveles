import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:noveles/features/domain/entities/entities.dart';

SliverAppBar sliverAppBarV1Book({
  required BuildContext context,
  required BookEntity books,
  required IconButton infoIcon,
}) {
  return SliverAppBar(
    title: const Text('Details'),
    actions: [
      infoIcon,
    ],
    backgroundColor: Colors.transparent,
    centerTitle: true,
    elevation: 0,
    expandedHeight: 360.0,
    flexibleSpace: SizedBox(
      height: 360.0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image(
              fit: BoxFit.cover,
              image: AssetImage(books.cover),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(10),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    Theme.of(context).colorScheme.onSurface,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 65.0,
            left: 16.0,
            right: 16.0,
            bottom: 0.0,
            child: SizedBox(
              child: Column(
                children: [
                  Expanded(
                    flex: 10,
                    child: Image(
                      fit: BoxFit.cover,
                      image: AssetImage(books.cover),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        books.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      books.author,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
