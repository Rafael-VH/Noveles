# Auth

> Integración con Supabase Auth — inicio de sesión, registro, cierre de sesión y
> estado de la sesión.

## Resumen

El feature Auth maneja la autenticación mediante Supabase Auth. Gestiona el ciclo
de vida completo de la sesión: login con email/contraseña, registro (que crea
automáticamente una fila de perfil en `profiles`), cierre de sesión y escucha en
tiempo real del estado de autenticación. El `AuthBloc` es un provider a nivel
raíz que maneja el ruteo basado en roles en `App`.

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| Login | `FR<UserEntity>` call(e,p) | Iniciar sesión con email/contraseña |
| Register | `FR<UserEntity>` call(e,p) | Crear cuenta + auto-perfil |
| `Logout` | `Future<Result<void>> call()` | Cerrar sesión actual |
| GetCurrentUser | `FR<UserEntity?>` call() | Obtener usuario de la sesión |
| ListenAuthState | `S<AuthEvent>` call() | Stream de eventos de auth |

**Repositorio**: `AuthRepository` → `AuthRepositoryImpl` usa
`SupabaseClientProvider` para llamar a `signInWithPassword`, `signUp`, `signOut`
y `onAuthStateChange`. Al iniciar sesión o registrarse, obtiene (o crea
automáticamente) la fila de `profiles`.

## BLoC

**`AuthBloc`** (`lib/features/auth/presentation/bloc/auth_bloc.dart`):

| Evento | Descripción |
| ------ | ----------- |
| `CheckAuthSession` | Verificar si existe una sesión al iniciar la app |
| `LoginRequested` | Ejecutar login con email/contraseña |
| `RegisterRequested` | Ejecutar registro con email/contraseña |
| `LogoutRequested` | Ejecutar cierre de sesión |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `AuthInitial` | — | Inicio de la app |
| `AuthLoading` | — | Procesando solicitud de auth |
| `AuthAuthenticated` | `UserEntity user` | Sesión activa |
| `AuthUnauthenticated` | — | Sin sesión |
| `AuthError` | `String message` | Error de autenticación |

El BLoC también escucha el stream de `ListenAuthState` y auto-despacha
`LogoutRequested` ante eventos de cierre de sesión externos (ej., expiración de
token).

## Pantallas

### LoginScreen

**Archivo**: `lib/features/auth/presentation/screens/login_screen.dart`

- Formulario de email + contraseña con validación
- Navegación a la pantalla de registro
- Muestra snackbar de error en caso de fallo

### RegisterScreen

**Archivo**: `lib/features/auth/presentation/screens/register_screen.dart`

- Formulario de registro con email + contraseña
- Crea automáticamente la fila de perfil con rol `user`

## Registro en DI

**Archivo**: `lib/core/di/injection_auth.dart`

- `AuthRepository` → `LazySingleton` (vía `AuthRepositoryImpl`)
- `Login`, `Register`, `Logout`, `GetCurrentUser`, `ListenAuthState` →
  `LazySingleton` cada uno
- `AuthBloc` → `Factory`

## Relacionados

- [Entidades](../../es/domain/entities.md) — campos de `UserEntity` (del feature
  profiles)
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de Auth
- [Tipos de usuario](../../es/user-types/regular-user.md) — Acceso basado en rol
- [Manejo de errores](../../es/architecture/error-handling.md) — `AuthFailure`,
  `ProfileFailure`
- [Ruteo](../../es/architecture/routing.md) — Selección de pantalla de inicio
  según rol

← Volver al [índice](../../es/README.md)
