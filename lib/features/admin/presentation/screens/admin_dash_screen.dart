import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/bootstrap/injection.dart';
import 'package:noveles/core/presentation/widgets/double_back_exit.dart';
import 'package:noveles/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:noveles/shared/presentation/widgets/snackbar_helper.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_analytics_event.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:noveles/features/admin/presentation/screens/analytics_tab.dart';
import 'package:noveles/features/admin/presentation/screens/books_tab.dart';
import 'package:noveles/features/admin/presentation/screens/genres_tab.dart';
import 'package:noveles/features/admin/presentation/screens/summary_tab.dart';
import 'package:noveles/features/admin/presentation/screens/users_tab.dart';
import 'package:noveles/features/labels/presentation/screens/label_management_screen.dart';
import 'package:noveles/features/labels/presentation/screens/label_rules_admin_tab.dart';
import 'package:noveles/features/app/presentation/widgets/app_drawer.dart';
import 'package:noveles/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class AdminDashScreen extends StatefulWidget {
  const AdminDashScreen({super.key});

  @override
  State<AdminDashScreen> createState() => _AdminDashScreenState();
}

class _AdminDashScreenState extends State<AdminDashScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : '';
    final adminEmail = authState is AuthAuthenticated ? authState.user.email : '';

    return DoubleBackExit(
      child: Scaffold(
        drawer: AppDrawer(
          role: UserRole.admin,
          onNavigateToLabels: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LabelManagementScreen()),
            );
          },
        ),
        appBar: AppBar(
          title: const Text('Panel Admin'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  adminEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar Sesión',
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<AdminBloc>()..add(const LoadAdminBooks()),
            ),
            BlocProvider(
              create: (_) => AdminUsersBloc(
                getAllProfiles: getIt(),
                updateUserRole: getIt(),
                currentUserId: currentUserId,
              )..add(const LoadAdminUsers()),
            ),
            BlocProvider(
              create: (_) =>
                  getIt<AdminAnalyticsBloc>()..add(const LoadAnalytics()),
            ),
          ],
          child: BlocListener<AdminUsersBloc, AdminUsersState>(
            listener: (context, state) {
              if (state is AdminUsersError) {
                showErrorSnack(context, state.message);
              }
            },
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is AdminLoaded && state.message != null) {
                  showSuccessSnack(context, state.message!);
                }
                if (state is AdminError) {
                  showErrorSnack(context, state.message);
                }
              },
              builder: (context, state) => IndexedStack(
                index: _currentIndex,
                children: [
                  const SummaryTab(),
                  BooksTab(state: state),
                  const GenresTab(),
                  const UsersTab(),
                  const LabelRulesAdminTab(),
                  const AnalyticsTab(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Resumen',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books),
              label: 'Libros',
            ),
            NavigationDestination(
              icon: Icon(Icons.category_outlined),
              selectedIcon: Icon(Icons.category),
              label: 'Géneros',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outlined),
              selectedIcon: Icon(Icons.people),
              label: 'Usuarios',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Etiquetas',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Analíticas',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final bloc = context.read<AuthBloc>();
    showConfirmationDialog(
      context: context,
      title: 'Cerrar Sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
      confirmLabel: 'Cerrar Sesión',
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(LogoutRequested());
      }
    });
  }
}
