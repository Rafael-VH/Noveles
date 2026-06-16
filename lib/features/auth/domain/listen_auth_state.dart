import 'dart:async';
import 'package:noveles/features/auth/domain/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class ListenAuthState {
  final AuthRepository repository;

  ListenAuthState(this.repository);

  Stream<AuthChangeEvent> call() => repository.onAuthStateChange();
}
