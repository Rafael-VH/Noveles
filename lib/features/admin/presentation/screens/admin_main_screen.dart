import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/di/injection.dart';
import 'package:noveles/features/presentation/bloc/bloc.dart';
import 'package:noveles/features/admin/presentation/screens/analytics_tab.dart';
import 'package:noveles/features/admin/presentation/screens/books_tab.dart';
import 'package:noveles/features/admin/presentation/screens/genres_tab.dart';
import 'package:noveles/features/admin/presentation/screens/users_tab.dart';
import 'package:noveles/features/presentation/widgets/app_drawer.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(isAdmin: true),
      appBar: AppBar(title: const Text('Panel Admin')),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<AdminBloc>()..add(const LoadAdminBooks()),
          ),
          BlocProvider(
            create: (_) => getIt<AdminUsersBloc>()..add(const LoadAdminUsers()),
          ),
        ],
        child: BlocListener<AdminUsersBloc, AdminUsersState>(
          listener: (context, state) {
            if (state is AdminUsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          child: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            }
            if (state is AdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) => IndexedStack(
            index: _currentIndex,
            children: [
              BooksTab(state: state),
              const GenresTab(),
              const UsersTab(),
              const AnalyticsTab(),
            ],
          ),
        ),
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Libros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Géneros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analíticas',
          ),
        ],
      ),
    );
  }
}
