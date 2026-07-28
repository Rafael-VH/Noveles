import 'package:flutter/material.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/app_drawer_header.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/drawer_section_label.dart';
import 'package:noveles/features/app/presentation/widgets/drawer/logout_footer.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class AppDrawer extends StatelessWidget {
  final UserEntity? user;
  final UserRole? role;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToFavorites;
  final VoidCallback? onNavigateToLabels;
  final VoidCallback? onLogout;

  const AppDrawer({
    super.key,
    this.user,
    this.role,
    this.onNavigateToProfile,
    this.onNavigateToFavorites,
    this.onNavigateToLabels,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    if (role == null) {
      return NavigationDrawer(
        selectedIndex: 0,
        onDestinationSelected: (index) => Navigator.pop(context),
        children: [
          const AppDrawerHeader.simplified(),
          NavigationDrawerDestination(
            icon: const Icon(Icons.login),
            label: const Text('Iniciar Sesión'),
          ),
        ],
      );
    }

    return NavigationDrawer(
      selectedIndex: 0,
      onDestinationSelected: (index) =>
          _handleNavigation(index, role!, context),
      header: AppDrawerHeader(user: user),
      footer: LogoutFooter(onLogout: onLogout),
      children: _buildDestinations(role!),
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
        onNavigateToProfile?.call();
      case DrawerItemType.favorites:
        Navigator.pop(context);
        onNavigateToFavorites?.call();
      case DrawerItemType.labels:
        Navigator.pop(context);
        onNavigateToLabels?.call();
    }
  }
}

enum DrawerItemType {
  home,
  panelScan,
  panelAdmin,
  editProfile,
  favorites,
  labels
}

final Map<DrawerItemType, (IconData, IconData, String)> _drawerItemConfig = {
  DrawerItemType.home: (
    Icons.home_outlined,
    Icons.home,
    'Inicio',
  ),
  DrawerItemType.panelScan: (
    Icons.qr_code_scanner_outlined,
    Icons.qr_code_scanner,
    'Panel Scan',
  ),
  DrawerItemType.panelAdmin: (
    Icons.admin_panel_settings_outlined,
    Icons.admin_panel_settings,
    'Panel Admin',
  ),
  DrawerItemType.editProfile: (
    Icons.person_outlined,
    Icons.person,
    'Editar Perfil',
  ),
  DrawerItemType.favorites: (
    Icons.favorite_outlined,
    Icons.favorite,
    'Mis Favoritos',
  ),
  DrawerItemType.labels: (
    Icons.label_outlined,
    Icons.label,
    'Etiquetas',
  ),
};

final Map<UserRole, List<(String, List<DrawerItemType>)>> _roleSections = {
  UserRole.user: [
    (
      'Navegación',
      [
        DrawerItemType.home,
      ],
    ),
    (
      'Perfil',
      [
        DrawerItemType.editProfile,
        DrawerItemType.favorites,
      ]
    ),
  ],
  UserRole.scan: [
    (
      'Navegación',
      [
        DrawerItemType.panelScan,
      ]
    ),
    (
      'Perfil',
      [
        DrawerItemType.editProfile,
      ]
    ),
  ],
  UserRole.admin: [
    (
      'Navegación',
      [
        DrawerItemType.panelAdmin,
      ]
    ),
    (
      'Perfil',
      [
        DrawerItemType.editProfile,
      ]
    ),
  ],
};
