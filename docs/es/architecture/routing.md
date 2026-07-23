# Routing

> Selección de pantalla de inicio según el rol, rutas nombradas y
> comportamiento del guardia de autenticación.

## Resumen

Noveles usa un patrón de **routing basado en roles** en lugar de una tabla de
rutas tradicional. El widget `App` (`lib/core/app/app.dart`) escucha el estado
de `AuthBloc` y renderiza la pantalla de inicio correspondiente según el rol del
usuario autenticado. Solamente existen dos rutas nombradas; toda otra navegación
es imperativa.

## Tabla de Rutas

| Ruta | Widget | Acceso | Tipo |
| ---- | ------ | ------ | ---- |
| `/admin` | `AdminDashScreen` | Solo admin | Ruta nombrada |
| `/label-management` | `LabelManagementScreen` | Scan + Admin | Ruta nombrada |
| Home (por defecto) | Depende del rol | Todos los roles | Parámetro `home:` |

Todas las demás pantallas usan `Navigator.push(MaterialPageRoute(...))`
imperativo.

## Guardia de Autenticación

La app **no** usa un guardia de autenticación basado en middleware. En cambio,
el `BlocBuilder<AuthBloc, AuthState>` en `App.build()` actúa como guardia:

```text
AuthLoading → CircularProgressIndicator
AuthAuthenticated → Pantalla de inicio según rol
AuthUnauthenticated → LoginScreen
AuthError → LoginScreen (con snackbar)
```text

**Usuarios suspendidos**: Un usuario con `role == UserRole.suspended` no cumple
con `isAdmin`, `isScan` ni `isUser`, por lo que cae al fallback `return const
LoginScreen()`. La snackbar de error de autenticación muestra el mensaje de
fallo. Esto bloquea efectivamente a los usuarios suspendidos de acceder a
cualquier pantalla.

## Lógica de Routing por Rol

El árbol de decisión de routing en `app.dart`:

```dart
if (authState is AuthAuthenticated)
  ├── user.isAdmin    → AdminDashScreen
  ├── user.isScan     → ScanMainScreen
  ├── user.isUser     → MainScreen
  └── else            → LoginScreen  (suspendido / rol desconocido)
else
  └── LoginScreen
```text

**El orden importa**: `isAdmin` se verifica primero, luego `isScan`, luego
`isUser`. Esto significa que un admin siempre obtiene el panel de admin incluso
si por algún motivo también tuviera otras banderas de rol.

## Registro de Rutas Nombradas

Definidas en `MaterialApp.routes`:

```dart
routes: {
  '/label-management': (_) => const LabelManagementScreen(),
  '/admin': (_) => const AdminDashScreen(),
},
```text

Se navega mediante `Navigator.pushNamed(context, '/admin')` desde el drawer.

## Proveedores de BLoC a Nivel de App

`App` provee dos BLoCs raíz:

| BLoC | Ámbito | Propósito |
| ---- | ------ | --------- |
| `ThemeBloc` | Global | Estado del tema (claro/oscuro) |
| `AuthBloc` | Global | Sesión de auth + routing por rol |

El `AuthBloc` se crea desde GetIt (`getIt<AuthBloc>()`) y dispara
`CheckAuthSession` inmediatamente.

## Manejo de Errores

`BlocListener<AuthBloc, AuthState>` en `App` escucha estados `AuthError` y
muestra un `SnackBar` con el mensaje de error y el esquema de color de error.
Esto brinda retroalimentación para verificaciones de sesión fallidas sin salir
de la pantalla actual.

## Relacionados

- [App Feature](../features/app/README.md) — MainScreen, detalles de AppDrawer
- [Auth Feature](../features/auth/README.md) — AuthBloc y gestión de sesión
- [Tema](./theme.md) — Integración de ThemeBloc
- [Tipos de Usuario](../user-types/regular-user.md) — Pantalla de inicio del
  usuario regular
- [Tipos de Usuario](../user-types/scan-user.md) — Pantalla de inicio del
  usuario scan
- [Tipos de Usuario](../user-types/admin-user.md) — Pantalla de inicio del
  admin

← Volver al [índice](../README.md)
