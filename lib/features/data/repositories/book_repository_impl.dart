import 'package:noveles/core/supabase/supabase_client.dart';
import 'package:noveles/features/domain/entities/entities.dart';
import 'package:noveles/features/domain/repositories/repositories.dart';

class BookRepositoryImpl implements BookRepository {
  @override
  Future<List<BookEntity>> getBooks() async {
    try {
      final response = await supabase
          .from('books')
          .select(
              '*, authors!inner(*), books_genres!inner(genre_id, genres(*)), tooks(*, chapters(*))')
          .order('id')
          .limit(100);

      return response.map((json) => _mapToBookEntity(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener libros: $e');
    }
  }

  @override
  Future<BookEntity?> getBookById(int id) async {
    try {
      final response = await supabase
          .from('books')
          .select(
              '*, authors!inner(*), books_genres!inner(genre_id, genres(*)), tooks(*, chapters(*))')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return _mapToBookEntity(response);
    } catch (e) {
      throw Exception('Error al obtener libro: $e');
    }
  }

  BookEntity _mapToBookEntity(Map<String, dynamic> json) {
    final authorData = Map<String, dynamic>.from(json['authors']);

    final listGenre = (json['books_genres'] as List<dynamic>).map((bg) {
      final g = Map<String, dynamic>.from(bg['genres']);
      return GenreEntity(
        id: g['id'],
        createdAt: DateTime.parse(g['created_at']),
        name: g['name'] ?? '',
        description: g['description'] ?? '',
      );
    }).toList();

    final listTook = (json['tooks'] as List<dynamic>).map((t) {
      final took = Map<String, dynamic>.from(t);
      final chapters = (took['chapters'] as List<dynamic>).map((ch) {
        return ChapterEntity(
          id: ch['id'],
          createdAt: DateTime.parse(ch['created_at']),
          number: ch['number'] ?? '',
          title: ch['title'] ?? '',
          content: ch['content'] ?? '',
          tookId: ch['took_id'] ?? 0,
        );
      }).toList();
      return TookEntity(
        id: took['id'],
        createdAt: DateTime.parse(took['created_at']),
        cover: took['cover'] ?? '',
        number: took['number'] ?? '',
        title: took['title'] ?? '',
        chapterCount: took['content'] ?? '',
        bookId: took['book_id'] ?? 0,
        listChapter: chapters,
      );
    }).toList();

    return BookEntity(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      cover: json['cover'] ?? '',
      name: json['name'] ?? '',
      short: json['short'] ?? '',
      alternative: json['alternative'] ?? '',
      description: json['description'] ?? '',
      authorId: json['author_id'] ?? 0,
      author: authorData['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      type: json['type'] ?? '',
      release: json['release'] ?? '',
      tookCount: json['took_count'] ?? '',
      chapterCount: json['chapter_count'] ?? '',
      source: json['source'] ?? '',
      link: json['link'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      listGenre: listGenre,
      listTook: listTook,
    );
  }

  @override
  Future<void> createBook(BookEntity book) async {
    try {
      await supabase.from('books').insert({
        'id': book.id,
        'created_at': book.createdAt.toIso8601String(),
        'cover': book.cover,
        'name': book.name,
        'short': book.short,
        'alternative': book.alternative,
        'description': book.description,
        'author_id': book.authorId,
        'country': book.country,
        'state': book.state,
        'type': book.type,
        'release': book.release,
        'took_count': book.tookCount,
        'chapter_count': book.chapterCount,
        'source': book.source,
        'link': book.link,
        'is_favorite': book.isFavorite,
      });
    } catch (e) {
      throw Exception('Error al crear libro: $e');
    }
  }

  @override
  Future<void> updateBook(BookEntity book) async {
    try {
      await supabase.from('books').update({
        'cover': book.cover,
        'name': book.name,
        'short': book.short,
        'alternative': book.alternative,
        'description': book.description,
        'author_id': book.authorId,
        'country': book.country,
        'state': book.state,
        'type': book.type,
        'release': book.release,
        'took_count': book.tookCount,
        'chapter_count': book.chapterCount,
        'source': book.source,
        'link': book.link,
        'is_favorite': book.isFavorite,
      }).eq('id', book.id);
    } catch (e) {
      throw Exception('Error al actualizar libro: $e');
    }
  }

  @override
  Future<void> deleteBook(int id) async {
    try {
      await supabase.from('books').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar libro: $e');
    }
  }
}
