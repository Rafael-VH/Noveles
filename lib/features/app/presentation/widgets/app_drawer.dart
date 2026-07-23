import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/app_drawer_header.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/drawer_section_label.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/logout_footer.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:noveles/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:noveles/features/labels/presentation/screens/label_management_screen.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';
import 'package:noveles/features/profiles/presentation/screens/profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final UserEntity? user;
  final UserRole? role;

  const AppDrawer({super.key, this.user, this.role});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthInitial || authState is AuthLoading) {
          return const SizedBox.shrink();
        }

        if (authState is AuthAuthenticated && !authState.user.isSuspended) {
          final userRole = authState.user.role;
          return NavigationDrawer(
            selectedIndex: 0,
            onDestinationSelected: (index) =>
                _handleNavigation(index, userRole, context),
            header: AppDrawerHeader(user: authState.user),
            footer: const LogoutFooter(),
            children: _buildDestinations(userRole),
          );
        }

        // Unauthenticated or suspended
        return NavigationDrawer(
          selectedIndex: 0,
          onDestinationSelected: (index) => Navigator.pop(context),
          children: [
            const AppDrawerHeader.simplified(),
            NavigationDrawerDestination(
              icon: Icon(Icons.login),
              label: const Text('Iniciar Sesión'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildDestinations(UserRole role) {
    final sections = _roleSections[role];
    if (sections == null) return [];

    final destinations = <Widget>[];
    for (final section in sections) {
      final sectionName = section.$1;
      final items = section.$2;
      destinations.add(DrawerSectionLabel(sectionName));
      for (final item in items) {
        final config = _drawerItemConfig[item]!;
        destinations.add(
          NavigationDrawerDestination(
            icon: Icon(config.$1),
            selectedIcon: Icon(config.$2),
            label: Text(config.$3),
          ),
        );
      }
    }
    return destinations;
  }

  void _handleNavigation(
    int selectedIndex,
    UserRole role,
    BuildContext context,
  ) {
    final sections = _roleSections[role];
    if (sections == null) return;

    final items = sections.expand((s) => s.$2).toList();
    if (selectedIndex >= items.length) return;

    switch (items[selectedIndex]) {
      case DrawerItemType.home:
      case DrawerItemType.panelScan:
        Navigator.pop(context);
      case DrawerItemType.panelAdmin:
        Navigator.pop(context);
        Navigator.pushNamed(context, '/admin');
      case DrawerItemType.editProfile:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      case DrawerItemType.favorites:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<FavoriteBloc>(),
              child: const FavoritesScreen(),
            ),
          ),
        );
      case DrawerItemType.labels:
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LabelManagementScreen(),
          ),
        );
    }
  }
}

enum DrawerItemType { home, panelScan, panelAdmin, editProfile, favorites, labels }

final Map<DrawerItemType,
    (IconData, IconData, String)> _drawerItemConfig = {
  DrawerItemType.home: (Icons.home_outlined, Icons.home, 'Inicio'),
  DrawerItemType.panelScan:
      (Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 'Panel Scan'),
  DrawerItemType.panelAdmin: (
    Icons.admin_panel_settings_outlined,
    Icons.admin_panel_settings,
    'Panel Admin',
  ),
  DrawerItemType.editProfile: (Icons.person_outlined, Icons.person, 'Editar Perfil'),
  DrawerItemType.favorites:
      (Icons.favorite_outlined, Icons.favorite, 'Mis Favoritos'),
  DrawerItemType.labels: (Icons.label_outlined, Icons.label, 'Etiquetas'),
};

final Map<UserRole, List<(String, List<DrawerItemType>)>> _roleSections = {
  UserRole.user: [
    ('Navegación', [DrawerItemType.home]),
    ('Perfil', [DrawerItemType.editProfile, DrawerItemType.favorites]),
  ],
  UserRole.scan: [
    ('Navegación', [DrawerItemType.panelScan]),
    ('Perfil', [DrawerItemType.editProfile]),
    ('Gestión', [DrawerItemType.labels]),
  ],
  UserRole.admin: [
    ('Navegación', [DrawerItemType.panelAdmin]),
    ('Perfil', [DrawerItemType.editProfile]),
  ],
};
