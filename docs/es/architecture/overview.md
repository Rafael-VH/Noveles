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
├── domain/
│   ├── *_entity.dart          # Entidades de dominio (Equatable)
│   ├── *_repository.dart      # Interfaz abstracta de repositorio
│   └── *_use_case.dart        # Casos de uso de lógica de negocio
├── data/
│   └── *_repository_impl.dart # Implementación de repositorio (llamadas Supabase)
└── presentation/
    ├── bloc/                  # Gestión de estado BLoC / Cubit
    └── screens/               # Pantallas de UI y widgets
```text

**11 módulos de funcionalidad**: `admin`, `app`, `auth`, `books`, `chapters`,
`favorites`, `genres`, `labels`, `profiles`, `scan`, `tooks`.

### Capa Core (`lib/core/`)

Infraestructura compartida de la que dependen todas las funcionalidades:

| Carpeta | Propósito |
| ------- | --------- |
| `app/` | Widget `App`, routing, selección de home por rol |
| `constants/` | Nombres de buckets de Storage (`StorageConstants`) |
| `cover/` | Utilidades para imágenes de portada |
| `di/` | Configuración de inyección de dependencias GetIt (11 módulos) |
| `errors/` | Clase sellada `Result<T>`, jerarquía de `Failure` |
| `presentation/` | ThemeBloc, sistema de notificaciones, widgets compartidos |
| `supabase/` | Proveedor de cliente Supabase, caché de capítulos |
| `utils/` | Colores, definiciones de tema, parseo, logging |

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
      │              │           └── Las implementaciones de Repo llaman a Supabase
      │              └── Dart puro: entidades, casos de uso, interfaces de repo
      └── Los BLoCs llaman casos de uso, mapean `Result<T>` a estado
```text

**Principio clave**: La capa de Domain es **Dart puro** — sin imports de
Flutter, sin imports de Supabase. Esto hace que las entidades y casos de uso
sean testeables sin ninguna dependencia del framework.

### Cómo se Conectan las Dependencias

GetIt conecta las capas en tiempo de ejecución:

1. `lib/core/di/injection.dart` llama a `setupDependencies()`
2. Cada funcionalidad tiene `injection_{feature}.dart` registrando sus propias
   dependencias
3. Repositorios: `registerLazySingleton` (se crean una vez, se comparten)
4. BLoCs: `registerFactory` (instancia nueva por solicitud)

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
| Backend | Supabase | Auth + BD + Storage en una sola plataforma |

---

> Última verificación: 2026-07-21
