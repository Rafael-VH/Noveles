import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class BookRepositoryImpl implements BookRepository {
  @override
  Future<List<BookEntity>> getBooks() async {
    final response = await supabase
        .from('books')
        .select('*, books_genres!inner(genre_id, genres(*)), tooks(*, chapters(*))')
        .order('id');

    return response.map((json) => _mapToBookEntity(json)).toList();
  }

  @override
  Future<BookEntity?> getBookById(int id) async {
    final response = await supabase
        .from('books')
        .select('*, books_genres!inner(genre_id, genres(*)), tooks(*, chapters(*))')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _mapToBookEntity(response);
  }

  BookEntity _mapToBookEntity(Map<String, dynamic> json) {
    final listGenre = (json['books_genres'] as List<dynamic>)
        .map((bg) => GenreEntity.fromMap(Map<String, dynamic>.from(bg['genres'])))
        .toList();

    final listTook = (json['tooks'] as List<dynamic>)
        .map((t) {
          final took = Map<String, dynamic>.from(t);
          final chapters = (took['chapters'] as List<dynamic>)
              .map((ch) => ChapterEntity.fromMap(Map<String, dynamic>.from(ch)))
              .toList();
          took['listChapter'] = chapters;
          return TookEntity.fromMap(took);
        })
        .toList();

    return BookEntity(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      cover: json['cover'] ?? '',
      name: json['name'] ?? '',
      short: json['short'] ?? '',
      alternative: json['alternative'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      type: json['type'] ?? '',
      release: json['release'] ?? '',
      took: json['took'] ?? '',
      chapter: json['chapter'] ?? '',
      source: json['source'] ?? '',
      link: json['link'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      listGenre: listGenre,
      listTook: listTook,
    );
  }

  @override
  Future<void> createBook(BookEntity book) async {
    await supabase.from('books').insert(book.toMap());
  }

  @override
  Future<void> updateBook(BookEntity book) async {
    await supabase.from('books').update(book.toMap()).eq('id', book.id);
  }

  @override
  Future<void> deleteBook(int id) async {
    await supabase.from('books').delete().eq('id', id);
  }
}
