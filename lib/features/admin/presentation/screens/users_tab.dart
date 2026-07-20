import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/features/admin/presentation/bloc/admin_users_bloc.dart';
import 'package:noveles/features/profiles/domain/user_entity.dart';
import 'package:noveles/features/profiles/domain/user_role.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar usuarios...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
            builder: (context, state) {
              if (state is AdminUsersLoading || state is AdminUsersInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AdminUsersLoaded) {
                var users = state.users;
                if (_searchQuery.isNotEmpty) {
                  users = users.where((u) {
                    final query = _searchQuery.toLowerCase();
                    return (u.displayName?.toLowerCase().contains(query) ??
                            false) ||
                        u.email.toLowerCase().contains(query);
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No se encontraron usuarios'
                          : 'No hay usuarios',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.isSuspended
                            ? Theme.of(context).colorScheme.errorContainer
                            : user.role == UserRole.admin
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                        child: Text(
                          (user.displayName ?? user.email)[0].toUpperCase(),
                        ),
                      ),
                      title: Text(user.displayName ?? user.email),
                      subtitle: Text(user.email),
                      onTap: () => _showRoleDialog(context, user),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RoleBadge(role: user.role),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              user.isSuspended
                                  ? Icons.person_add
                                  : Icons.block,
                              color: user.isSuspended
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                            tooltip: user.isSuspended
                                ? 'Reactivar'
                                : 'Suspender',
                            onPressed: () {
                              context
                                  .read<AdminUsersBloc>()
                                  .add(SuspendUser(targetUserId: user.id));
                            },
                          ),
                        ],
                      ),
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
          ),
        ),
      ],
    );
  }

  void _showRoleDialog(BuildContext context, UserEntity user) {
    final roles = [UserRole.user, UserRole.scan, UserRole.admin];
    final roleLabels = {
      UserRole.user: 'Usuario',
      UserRole.scan: 'Scanner',
      UserRole.admin: 'Admin',
    };

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Cambiar rol de ${user.displayName ?? user.email}'),
        children: roles
            .map(
              (role) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdminUsersBloc>().add(
                        ChangeUserRole(
                          targetUserId: user.id,
                          newRole: role.name,
                        ),
                      );
                },
                child: Row(
                  children: [
                    Icon(
                      user.role == role ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(roleLabels[role] ?? role.name),
                    if (user.role == role) ...[
                      const SizedBox(width: 8),
                      const Chip(
                        label: Text('Actual', style: TextStyle(fontSize: 10)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final UserRole role;
  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == UserRole.admin;
    final isSuspended = role == UserRole.suspended;

    Color bgColor;
    Color fgColor;
    String label;

    if (isSuspended) {
      bgColor = Theme.of(context).colorScheme.errorContainer;
      fgColor = Theme.of(context).colorScheme.onErrorContainer;
      label = 'Suspendido';
    } else if (isAdmin) {
      bgColor = Theme.of(context).colorScheme.primaryContainer;
      fgColor = Theme.of(context).colorScheme.onPrimaryContainer;
      label = 'Admin';
    } else {
      bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      fgColor = Theme.of(context).colorScheme.onSurfaceVariant;
      label = role.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fgColor,
        ),
      ),
    );
  }
}
