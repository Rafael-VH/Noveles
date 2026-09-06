import 'package:flutter/material.dart';
import 'package:noveles/features/auth/presentation/screens/login_screen.dart';

/// Blocking screen shown when the signed-in profile is `suspended` (or has an
/// unrecognized role). The [AuthBloc] forces a sign-out before navigating here,
/// so the user lands on Login after dismissing this screen.
class SuspendedScreen extends StatelessWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Cuenta suspendida',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tu cuenta fue suspendida. Si creés que es un error, '
                'contactate con el administrador.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (_) => false,
                ),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
