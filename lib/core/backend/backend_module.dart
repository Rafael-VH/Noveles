import 'package:get_it/get_it.dart';
import 'package:noveles/core/backend/auth_gateway.dart';
import 'package:noveles/core/backend/data_gateway.dart';
import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:noveles/core/backend/supabase/supabase_auth_gateway.dart';
import 'package:noveles/core/backend/supabase/supabase_config.dart';
import 'package:noveles/core/backend/supabase/supabase_data_gateway.dart';
import 'package:noveles/core/backend/supabase/supabase_storage_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Boots the backend SDK.
///
/// `main.dart` calls this without knowing which vendor it is, so replacing the
/// backend means editing this file — not the app's entry point.
Future<void> initializeBackend() async {
  final config = await SupabaseConfig.resolve();
  await Supabase.initialize(url: config.url, anonKey: config.anonKey);
}

/// The vendor's client accessor, isolated to this single line.
SupabaseClient _client() => Supabase.instance.client;

/// Registers the backend ports.
///
/// This is the single place that decides which implementation backs the app.
/// Adding a second backend means binding these three interfaces to different
/// adapters here — no feature code changes.
///
/// The client is resolved lazily, inside the factories: touching
/// `Supabase.instance` at registration time would require an initialised SDK
/// just to build the object graph.
void registerBackendDependencies(GetIt getIt) {
  getIt.registerLazySingleton<DataGateway>(
    () => SupabaseDataGateway(_client()),
  );
  getIt.registerLazySingleton<AuthGateway>(
    () => SupabaseAuthGateway(_client()),
  );
  getIt.registerLazySingleton<StorageGateway>(
    () => SupabaseStorageGateway(_client()),
  );
}
