import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:noveles/features/books/domain/track_book_view.dart';

/// Fire-and-forget view tracker used when a [BookScreen] opens. Keeps the
/// timing/async concern out of the screen's state and receives its use case by
/// constructor (no service locator inside widgets).
class BookViewTracker extends StatefulWidget {
  final int bookId;
  final TrackBookView trackBookView;

  const BookViewTracker({
    super.key,
    required this.bookId,
    required this.trackBookView,
  });

  @override
  State<BookViewTracker> createState() => _BookViewTrackerState();
}

class _BookViewTrackerState extends State<BookViewTracker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Delay matches the previous behavior: only count the view if the user
    // stays on the screen for a moment (avoids counting accidental opens).
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        widget.trackBookView(widget.bookId);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
