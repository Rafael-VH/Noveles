import 'dart:async';
import 'package:noveles/features/domain/repositories/repositories.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class ListenAuthState {
  final AuthRepository repository;

  ListenAuthState(this.repository);

  Stream<AuthChangeEvent> call() => repository.onAuthStateChange();
}
