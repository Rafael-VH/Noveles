# Visión General de Arquitectura

> Clean Architecture implementada en Noveles — tres capas con reglas de
> dependencia estrictas.

← [Volver al índice](../README.md)

## Resumen

Noveles sigue **Clean Architecture** con tres capas concéntricas:

```text
┌─────────────────────────────────┐
│       Presentation              │  BLoCs, Screens, Widgets
├─────────────────────────────────┤
│         Domain                  │  Entities, Use Cases, Repository interfaces
├─────────────────────────────────┤
│           Data                  │  Repository implementations, Models
└─────────────────────────────────┘
```text

**Regla de dependencia**: Las capas internas nunca dependen de las externas.
Domain no sabe nada de Data ni de Presentation. Data depende de Domain (por las
interfaces de repositorio). Presentation depende de Domain (por entidades y casos
de uso).

## Mapeo de Carpetas

### Módulos de Funcionalidad (`lib/features/`)

Cada funcionalidad sigue la misma estructura de tres capas:

```text
lib/features/{feature}/
├── di/                        # Registro DI de la funcionalidad (injection_{feature}.dart)
├── domain/
│   ├── *_entity.dart          # Entidades de dominio (Equatable)
│   ├── *_repository.dart      # Interfaz abstracta de repositorio
│   └── *_use_case.dart        # Casos de uso de lógica de negocio
├── data/
│   └── *_repository_impl.dart # Implementación de repositorio (habla con los ports)
└── presentation/
    ├── bloc/                  # Gestión de estado BLoC / Cubit
    └── screens/               # Pantallas de UI y widgets
```text

**10 módulos de funcionalidad**: `admin`, `app`, `auth`, `books`, `chapters`,
`genres`, `labels`, `profiles`, `scan`, `tooks`.

### Capa Core (`lib/core/`)

Infraestructura compartida de la que dependen todas las funcionalidades:

| Carpeta | Propósito |
| ------- | --------- |
| `backend/` | Ports de backend (datos, auth, storage) más los adaptadores que los implementan — el único lugar que nombra un vendor |
| `constants/` | Nombres de buckets de Storage (`StorageConstants`) |
| `cover/` | Utilidades para imágenes de portada |
| `errors/` | Clase sellada `Result<T>`, jerarquía de `Failure` |
| `presentation/` | ThemeBloc, sistema de notificaciones, widgets compartidos |
| `utils/` | Colores, definiciones de tema, parseo, logging |

El composition root vive fuera de `core/`, en `lib/bootstrap/`:
`injection.dart` registra todas las dependencias y `app.dart` es el widget raíz.

### Capa Compartida (`lib/shared/`)

Código reutilizado entre varias funcionalidades:

| Carpeta | Propósito |
| ------- | --------- |
| domain/entities/ | BookWithRelations — libro + géneros, etiquetas, tomos |
| `presentation/widgets/` | Componentes de UI compartidos |

## Flujo de Dependencias

```text
Presentation ──→ Domain ←── Data
      │              │           │
      │              │           └── Las implementaciones de Repo llaman a los ports
      │              └── Dart puro: entidades, casos de uso, interfaces de repo
      └── Los BLoCs llaman casos de uso, mapean `Result<T>` a estado
```text

**Principio clave**: La capa de Domain es **Dart puro** — sin imports de
Flutter, sin imports de Supabase. Esto hace que las entidades y casos de uso
sean testeables sin ninguna dependencia del framework.

### Cómo se Conectan las Dependencias

GetIt conecta las capas en tiempo de ejecución:

1. `lib/bootstrap/injection.dart` define `setupDependencies()`
2. Primero llama a `registerBackendDependencies()`, que ata los tres ports a los
   adaptadores del backend actual
3. Cada funcionalidad tiene `lib/features/{feature}/di/injection_{feature}.dart` registrando sus propias
   dependencias
4. Repositorios: `registerLazySingleton` (se crean una vez, se comparten)
5. BLoCs: `registerFactory` (instancia nueva por solicitud)

## Manejo de Errores

Los casos de uso devuelven `Future<Result<T>>` donde `Result` es una clase
sellada:

- `Ok<T>` — éxito con valor
- `Err<T>` — fallo con un objeto `Failure`

Los BLoCs reciben el `Result`, extraen el valor o mapean `Failure` a estado de
error. Ver `lib/core/errors/result.dart` y `lib/core/errors/failure.dart`.

## Decisiones de Diseño Clave

| Decisión | Elección | Fundamentación |
| -------- | -------- | -------------- |
| Manejo de estado | BLoC | Transiciones de estado predecibles, testeable |
| DI | GetIt | Localizador de servicios simple, sin generación de código |
| Entidades | Equatable | Igualdad por valor para comparaciones de estado |
| Manejo de errores | Result<T> sellado | Errores explícitos, sin excepciones |
| Backend | Supabase, detrás de ports | Auth + BD + Storage en una sola plataforma, reemplazable sin tocar las features |

---

> Última verificación: 2026-07-24
