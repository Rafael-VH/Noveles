import 'dart:async';
import 'package:noveles/features/auth/domain/repositories/auth_repository.dart';
import 'package:noveles/features/auth/domain/entities/auth_event.dart';

class ListenAuthState {
  final AuthRepository repository;

  ListenAuthState(this.repository);

  Stream<AuthEvent> call() => repository.onAuthStateChange();
}
