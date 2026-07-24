# Profiles

> Perfiles de usuario — información de visualización, subida de avatar, cambio
> de contraseña y gestión de roles.

## Resumen

El feature Profiles gestiona los datos de perfil del usuario más allá de la
autenticación. Maneja el nombre visible, la biografía, la subida de avatar, el
cambio de contraseña y la gestión de roles a nivel admin (asignar roles,
suspender usuarios). El `UserEntity` se comparte en toda la aplicación como la
representación canónica del usuario.

## Modelo de datos

**`UserEntity`** (`lib/features/profiles/domain/user_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `String` | UUID de Supabase Auth |
| `email` | `String` | Email del usuario |
| `role` | `UserRole` | `user`, `scan`, `admin` o `suspended` |
| `displayName` | `String?` | Nombre visible |
| `bio` | `String?` | Biografía del usuario |
| `avatarUrl` | `String?` | Ruta de la imagen de avatar |

**Getters computados**: `isUser`, `isScan`, `isAdmin`, `isSuspended`

**Enum `UserRole`** (`lib/features/profiles/domain/user_role.dart`): `user`,
`scan`, `admin`, `suspended`

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetProfile | `FR<UE>` call() | Obtener perfil del usuario actual |
| UpdateProfile | `FR<UE>` call({String? d}) | Actualizar campos del perfil |
| UploadAvatar | `FR<String>` call(String fp) | Subir avatar a Storage |
| ChangePassword | `FR<void>` call(String np) | Cambiar contraseña |
| GetAllProfiles | `FR<L<UE>>` call({int p}) | Admin: listar usuarios |
| UpdateUserRole | `FR<UE>` call({required ... | Admin: cambiar rol de usuario |

**Repositorio**: `ProfilesRepository` → `ProfilesRepositoryImpl` consulta la
tabla `profiles` y Supabase Auth.

## BLoC

**`ProfileBloc`** (`lib/features/profiles/presentation/bloc/profile_bloc.dart`):

| Evento | Descripción |
| ------ | ----------- |
| `LoadProfile` | Cargar perfil del usuario actual |
| `UpdateProfile` | Actualizar nombre visible, biografía o avatar |
| `UploadAvatar` | Seleccionar y subir imagen de avatar |
| `ChangePassword` | Cambiar contraseña de la cuenta |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `ProfileInitial` | — | Inicial |
| `ProfileLoading` | — | Procesando |
| `ProfileLoaded` | `UserEntity profile` | Perfil cargado |
| `ProfileError` | `String message` | Error |

## Pantallas

### ProfileScreen

**Archivo**: `lib/features/profiles/presentation/screens/profile_screen.dart`

- Ver y editar nombre visible, biografía, avatar
- Sección de cambio de contraseña
- Subida de avatar con selector de imágenes

### Widgets

**Archivo**: `lib/features/profiles/presentation/screens/widgets/`

- Subcomponentes del perfil (selector de avatar, campos de formulario)

## Registro en DI

**Archivo**: `lib/features/profiles/di/injection_profiles.dart`

- `ProfilesRepository` → `LazySingleton`
- Todos los casos de uso → `LazySingleton`
- `ProfileBloc` → `Factory`

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de `UserEntity`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de
  Profiles
- [Tipos de usuario](../../es/user-types/regular-user.md) — Edición de perfil
- [Tipos de usuario](../../es/user-types/admin-user.md) — Gestión de roles
- [Base de datos](../../es/database/tables.md) — esquema de la tabla `profiles`
- [Manejo de errores](../../es/architecture/error-handling.md) —
  `ProfileFailure`

← Volver al [índice](../../es/README.md)
