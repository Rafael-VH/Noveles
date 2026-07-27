import 'package:flutter/material.dart';
import 'package:noveles/shared/presentation/widgets/confirmation_dialog.dart';

class LogoutFooter extends StatelessWidget {
  final VoidCallback? onLogout;

  const LogoutFooter({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.logout, color: theme.colorScheme.error),
          title: Text(
            'Cerrar Sesión',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () => _onLogout(context),
        ),
      ],
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Cerrar Sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
      confirmLabel: 'Cerrar Sesión',
      isDestructive: true,
    );
    if (confirmed == true) {
      onLogout?.call();
    }
  }
}
