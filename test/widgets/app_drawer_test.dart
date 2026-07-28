import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noveles/core/cover/cover_url_service.dart';
import 'package:noveles/features/app/presentation/widgets/app_drawer.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/app_drawer_header.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/drawer_section_label.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/logout_footer.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockCoverUrlService extends Mock implements CoverUrlService {
  @override
  String call(String? cover) => cover ?? '';
}

Widget buildAppDrawer({
  required MockAuthBloc authBloc,
  UserRole? role,
}) {
  return MaterialApp(
    home: Scaffold(
      body: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: AppDrawer(role: role),
      ),
    ),
  );
}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    if (!GetIt.instance.isRegistered<CoverUrlService>()) {
      GetIt.instance.registerLazySingleton<CoverUrlService>(
        () => MockCoverUrlService(),
      );
    }
  });

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('AppDrawer — role-based destinations', () {
    testWidgets('admin ve Panel Admin y Editar Perfil', (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '1', email: 'admin@test.com', role: UserRole.admin),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.admin));

      expect(find.text('Panel Admin'), findsOneWidget);
      expect(find.text('Editar Perfil'), findsOneWidget);
    });

    testWidgets('admin NO ve Inicio, Mis Favoritos ni Panel Scan',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '1', email: 'admin@test.com', role: UserRole.admin),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.admin));

      expect(find.text('Inicio'), findsNothing);
      expect(find.text('Mis Favoritos'), findsNothing);
      expect(find.text('Panel Scan'), findsNothing);
    });

    testWidgets('scan ve Panel Scan y Editar Perfil',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '2', email: 'scan@test.com', role: UserRole.scan),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.scan));

      expect(find.text('Panel Scan'), findsOneWidget);
      expect(find.text('Editar Perfil'), findsOneWidget);
    });

    testWidgets('scan NO ve Inicio, Panel Admin ni Mis Favoritos',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '2', email: 'scan@test.com', role: UserRole.scan),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.scan));

      expect(find.text('Inicio'), findsNothing);
      expect(find.text('Panel Admin'), findsNothing);
      expect(find.text('Mis Favoritos'), findsNothing);
    });

    testWidgets('reader ve Inicio, Editar Perfil y Mis Favoritos',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '3', email: 'user@test.com', role: UserRole.user),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.user));

      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.text('Mis Favoritos'), findsOneWidget);
    });

    testWidgets('reader NO ve Panel Admin, Panel Scan ni Etiquetas',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '3', email: 'user@test.com', role: UserRole.user),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.user));

      expect(find.text('Panel Admin'), findsNothing);
      expect(find.text('Panel Scan'), findsNothing);
      expect(find.text('Etiquetas'), findsNothing);
    });
  });

  group('AppDrawer — unauthenticated and edge cases', () {
    testWidgets('no autenticado muestra "Iniciar Sesión"', (tester) async {
      when(() => authBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc));

      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('no autenticado NO muestra items de rol', (tester) async {
      when(() => authBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc));

      expect(find.text('Panel Admin'), findsNothing);
      expect(find.text('Panel Scan'), findsNothing);
      expect(find.text('Inicio'), findsNothing);
      expect(find.text('Editar Perfil'), findsNothing);
      expect(find.text('Mis Favoritos'), findsNothing);
      expect(find.text('Etiquetas'), findsNothing);
    });

    testWidgets('no autenticado muestra header simplificado con "Noveles"',
        (tester) async {
      when(() => authBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc));

      expect(find.text('Noveles'), findsOneWidget);
      expect(find.text('Iniciá sesión para continuar'), findsOneWidget);
    });

    testWidgets('usuario suspendido muestra "Iniciar Sesión"',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '4', email: 'suspended@test.com', role: UserRole.suspended),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc));

      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('loading state muestra login drawer', (tester) async {
      when(() => authBloc.state).thenReturn(AuthLoading());

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc));

      // El drawer muestra login cuando no hay role (independiente del estado AuthBloc)
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Panel Admin'), findsNothing);
      expect(find.byType(NavigationDrawer), findsOneWidget);
    });
  });

  group('AppDrawer — section labels', () {
    testWidgets('admin ve sección "Navegación" y "Perfil"', (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '1', email: 'admin@test.com', role: UserRole.admin),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.admin));

      expect(find.text('Navegación'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('scan ve secciones "Navegación" y "Perfil"',
        (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '2', email: 'scan@test.com', role: UserRole.scan),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.scan));

      expect(find.text('Navegación'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('reader ve secciones "Navegación" y "Perfil"', (tester) async {
      when(() => authBloc.state).thenReturn(
        AuthAuthenticated(
          const UserEntity(id: '3', email: 'user@test.com', role: UserRole.user),
        ),
      );

      await tester.pumpWidget(buildAppDrawer(authBloc: authBloc, role: UserRole.user));

      expect(find.text('Navegación'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });
  });

  group('AppDrawerHeader', () {
    testWidgets('renderiza CircleAvatar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppDrawerHeader(
            user: const UserEntity(
              id: '1',
              email: 'user@test.com',
              role: UserRole.user,
              displayName: 'Test User',
            ),
          ),
        ),
      ));
      // CircleAvatar siempre existe (con imagen o fallback)
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('muestra icono person cuando no hay avatarUrl',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppDrawerHeader(
            user: const UserEntity(
              id: '1',
              email: 'user@test.com',
              role: UserRole.user,
              displayName: 'Test User',
            ),
          ),
        ),
      ));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('muestra displayName cuando existe', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppDrawerHeader(
            user: const UserEntity(
              id: '1',
              email: 'user@test.com',
              role: UserRole.user,
              displayName: 'Test User',
            ),
          ),
        ),
      ));

      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('muestra email como fallback cuando no hay displayName',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AppDrawerHeader(
            user: const UserEntity(
              id: '1',
              email: 'user@test.com',
              role: UserRole.user,
            ),
          ),
        ),
      ));

      // Debe mostrar email como título principal (sin displayName, usa email)
      expect(find.text('user@test.com'), findsOneWidget);
    });

    testWidgets('header simplificado muestra Noveles y texto de login',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const AppDrawerHeader.simplified(),
        ),
      ));

      expect(find.text('Noveles'), findsOneWidget);
      expect(find.text('Iniciá sesión para continuar'), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories), findsOneWidget);
    });
  });

  group('DrawerSectionLabel', () {
    testWidgets('renderiza el texto de la sección', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: const DrawerSectionLabel('Navegación'),
        ),
      ));

      expect(find.text('Navegación'), findsOneWidget);
    });
  });

  group('LogoutFooter', () {
    testWidgets('muestra Cerrar Sesión', (tester) async {
      when(() => authBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const LogoutFooter(),
          ),
        ),
      ));

      expect(find.text('Cerrar Sesión'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('tap en Cerrar Sesión abre diálogo de confirmación',
        (tester) async {
      when(() => authBloc.state).thenReturn(AuthUnauthenticated());

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const LogoutFooter(),
          ),
        ),
      ));

      // Tap en Cerrar Sesión
      await tester.tap(find.text('Cerrar Sesión'));
      await tester.pumpAndSettle();

      // Debe mostrar el diálogo de confirmación
      expect(find.text('¿Estás seguro de que deseas cerrar sesión?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      // 3 instancias: ListTile + título del diálogo + botón de confirmación
      expect(find.text('Cerrar Sesión'), findsNWidgets(3));
    });
  });
}
