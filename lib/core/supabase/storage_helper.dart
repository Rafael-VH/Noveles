import 'package:noveles/core/supabase/supabase_client.dart';

String coverUrl(String cover) =>
    supabase.storage.from('covers').getPublicUrl(cover);
