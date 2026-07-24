import 'package:equatable/equatable.dart';

class AnalyticsOverview extends Equatable {
  final int totalViews;
  final int viewsToday;
  final int totalBooks;
  final int visibleBooks;

  const AnalyticsOverview({
    required this.totalViews,
    required this.viewsToday,
    required this.totalBooks,
    required this.visibleBooks,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      totalViews: (json['total_views'] ?? 0) as int,
      viewsToday: (json['views_today'] ?? 0) as int,
      totalBooks: (json['total_books'] ?? 0) as int,
      visibleBooks: (json['visible_books'] ?? 0) as int,
    );
  }

  @override
  List<Object?> get props => [totalViews, viewsToday, totalBooks, visibleBooks];
}

class AnalyticsTrendEntry extends Equatable {
  final String viewDate;
  final int viewCount;

  const AnalyticsTrendEntry({
    required this.viewDate,
    required this.viewCount,
  });

  factory AnalyticsTrendEntry.fromJson(Map<String, dynamic> json) {
    return AnalyticsTrendEntry(
      viewDate: (json['view_date'] ?? '').toString(),
      viewCount: (json['view_count'] ?? 0) as int,
    );
  }

  @override
  List<Object?> get props => [viewDate, viewCount];
}

class AnalyticsTopBook extends Equatable {
  final String bookName;
  final int viewCount;

  const AnalyticsTopBook({
    required this.bookName,
    required this.viewCount,
  });

  factory AnalyticsTopBook.fromJson(Map<String, dynamic> json) {
    return AnalyticsTopBook(
      bookName: (json['book_name'] ?? '').toString(),
      viewCount: (json['view_count'] ?? 0) as int,
    );
  }

  @override
  List<Object?> get props => [bookName, viewCount];
}
