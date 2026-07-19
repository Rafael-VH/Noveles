import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/app/presentation/widgets/app_drawer.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(
      AuthAuthenticated(
        const UserEntity(id: '1', email: 'admin@test.com', role: 'admin'),
      ),
    );
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('AppDrawer', () {
    testWidgets('shows Panel Admin for admin users', (tester) async {
      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: Scaffold(
              body: AppDrawer(isAdmin: true),
            ),
          ),
        ),
      );

      expect(find.text('Panel Admin'), findsOneWidget);
    });

    testWidgets('shows Inicio for non-admin users', (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '1', email: 'scan@test.com', role: 'scan'),
        ),
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const MaterialApp(
            home: Scaffold(
              body: AppDrawer(isAdmin: false),
            ),
          ),
        ),
      );

      expect(find.text('Inicio'), findsOneWidget);
    });
  });
}
