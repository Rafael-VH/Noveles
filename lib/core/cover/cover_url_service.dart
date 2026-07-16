import 'package:noveles/core/constants/storage_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoverUrlService {
  final SupabaseClient _supabase;

  CoverUrlService(this._supabase);

  String call(String? cover) {
    if (cover == null || cover.isEmpty) return '';
    if (cover.startsWith('http')) return cover;
    return _supabase.storage.from(StorageConstants.coversBucket).getPublicUrl(cover);
  }
}
