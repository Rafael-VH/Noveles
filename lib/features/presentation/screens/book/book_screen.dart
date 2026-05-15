import 'package:flutter/material.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/presentation/pages/pages.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({
    super.key,
    required this.books,
  });

  final BookEntity books;

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BookPage(
        books: widget.books,
      ),
    );
  }
}
