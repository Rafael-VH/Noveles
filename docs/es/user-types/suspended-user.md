# Usuario Suspendido

> Acceso bloqueado — no puede navegar ni interactuar con la app.

## Resumen del Rol

`UserRole.suspended` es un estado bloqueado en el que el usuario no puede
acceder a ninguna funcionalidad de la app. Los usuarios suspendidos no pueden
iniciar sesión ni realizar ninguna acción. El rol es reversible — un admin puede
reactivar a un usuario suspendido.

**Valor del enum**: `UserRole.suspended`

**Fuente**: `lib/features/profiles/domain/user_role.dart`

## Base de Datos

La tabla `profiles` tiene una columna `role` con una restricción `CHECK` que
incluye `'suspended'`:

```sql
CHECK (role IN ('user', 'scan', 'admin', 'suspended'))
```text

**Fuente**: Esquema de migración de la base de datos

## Comportamiento de la App

Cuando un usuario suspendido intenta iniciar sesión:

1. **AuthBloc** recibe `AuthAuthenticated` con `user.isSuspended == true`
2. **La lógica de routing** en `lib/core/app/app.dart` verifica roles en orden:

   ```dart
   if (authState.user.isAdmin) { return AdminDashScreen(); }
   if (authState.user.isScan) { return ScanMainScreen(); }
   if (authState.user.isUser) { return MainScreen(); }
   return LoginScreen(); // Cae aquí para suspendidos
   ```

1. **Resultado**: Los usuarios suspendidos ven `LoginScreen` nuevamente (sin
   navegación a ninguna pantalla)
2. **No se muestra ningún mensaje de error** — el usuario simplemente no puede
   avanzar

**Nota**: El routing no verifica explícitamente `isSuspended`. Como `isUser`
devuelve `false` para usuarios suspendidos, caen al caso por defecto
`LoginScreen`.

## Acción del Admin

Los admins pueden suspender usuarios mediante `AdminUsersBloc`:

| Evento | Descripción |
| ------ | ----------- |
| `SuspendUser` | Alterna la suspensión para un usuario objetivo |

**Proceso**:

1. El admin abre la pestaña Usuarios en el panel de admin
2. Hace clic en el botón de suspender sobre un usuario
3. `AdminUsersBloc._onSuspendUser()` determina el estado actual:
   - Si el usuario está actualmente activo (`UserRole.user`) → cambia el rol a
     `UserRole.suspended`
   - Si el usuario está actualmente suspendido → restaura el rol a
     `UserRole.user` (reactivación)
4. Llama al caso de uso `UpdateUserRole` con el nuevo rol
5. Recarga la lista de usuarios y muestra un mensaje de confirmación

**Restricciones**:

- Los admins no pueden suspenderse a sí mismos (`'No puedes suspenderte a ti
  mismo'`)
- El ID del usuario objetivo se valida contra `currentUserId`

**Fuente**: `lib/features/admin/presentation/bloc/admin_users_bloc.dart`

## Relacionados

- [Usuario Regular](regular-user.md) — Rol activo por defecto
- [Usuario Admin](admin-user.md) — Quién puede suspender usuarios
- [Enum de Roles](../../es/architecture/overview.md) — Definiciones de roles

← Volver al [índice](../README.md)
