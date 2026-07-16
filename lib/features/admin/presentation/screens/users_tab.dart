import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_bloc.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersBloc, AdminUsersState>(
      builder: (context, state) {
        if (state is AdminUsersLoading || state is AdminUsersInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminUsersLoaded) {
          final users = state.users;
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.role == 'admin'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(
                    (user.displayName ?? user.email)[0].toUpperCase(),
                  ),
                ),
                title: Text(user.displayName ?? user.email),
                subtitle: Text(user.email),
                trailing: RoleBadge(role: user.role),
              );
            },
          );
        }

        if (state is AdminUsersError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<AdminUsersBloc>()
                      .add(const LoadAdminUsers()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'Admin' : role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isAdmin
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
