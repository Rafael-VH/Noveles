import 'dart:async';
import 'package:noveles/features/auth/domain/auth_repository.dart';
import 'package:noveles/features/auth/domain/auth_event.dart';

class ListenAuthState {
  final AuthRepository repository;

  ListenAuthState(this.repository);

  Stream<AuthEvent> call() => repository.onAuthStateChange();
}
