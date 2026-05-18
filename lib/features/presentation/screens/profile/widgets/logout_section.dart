import 'package:flutter/material.dart';

class LogoutSection extends StatelessWidget {
  final VoidCallback onConfirmLogout;

  const LogoutSection({
    super.key,
    required this.onConfirmLogout,
  });

  void _onTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirmLogout();
            },
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () => _onTap(context),
        child: Text(
          'Cerrar Sesión',
          style: TextStyle(
              color: Theme.of(context).colorScheme.error, fontSize: 16),
        ),
      ),
    );
  }
}
