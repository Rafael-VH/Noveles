import 'package:noveles/core/supabase/supabase_client.dart';

String coverUrl(String cover) {
  if (cover.isEmpty) return '';
  return supabase.storage.from('covers').getPublicUrl(cover);
}
