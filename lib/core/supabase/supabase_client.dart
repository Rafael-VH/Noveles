import 'package:supabase_flutter/supabase_flutter.dart';

/// Injectable provider for testability.
abstract class SupabaseClientProvider {
  SupabaseClient get client;
}

class SupabaseClientProviderImpl implements SupabaseClientProvider {
  @override
  SupabaseClient get client => Supabase.instance.client;
}
