import 'package:supabase_flutter/supabase_flutter.dart';

class CoverUrlService {
  final SupabaseClient _supabase;

  CoverUrlService(this._supabase);

  String call(String cover) {
    if (cover.isEmpty) return '';
    if (cover.startsWith('http')) return cover;
    return _supabase.storage.from('covers').getPublicUrl(cover);
  }
}
