import 'package:flutter/material.dart';
import 'package:noveles/features/main/data/local/models/model.dart';
import 'package:noveles/features/main/presentation/pages/pages.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({
    super.key,
    required this.books,
  });

  final BookLocalModel books;

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
