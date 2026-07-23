# Noveles

> Una app lectora de novelas en Flutter con acceso basado en roles,
> construida con Clean Architecture y Supabase.

## ¿Qué es esto?

Noveles es una aplicación móvil para leer y gestionar novelas. Soporta
tres roles de usuario — **Admin**, **Scan** (creador de contenido) y
**Usuario regular** — cada uno con pantallas y permisos adaptados. El
contenido se almacena en Supabase (Postgres + Storage), y la app sigue
Clean Architecture con manejo de estado BLoC.

**Estadísticas clave**: 10 entidades, 54 casos de uso, 19 BLoCs, 19
pantallas, 12 funcionalidades.

## Stack tecnológico

| Capa | Tecnología |
| ------- | ----------- |
| Framework | Flutter 3.3+ / Dart |
| Backend | Supabase (Postgres, Auth, Storage) |
| Estado | BLoC / Cubit |
| DI | GetIt |
| Testing | flutter_test, mocktail, bloc_test |

## Inicio rápido

→ [Guía de inicio](es/guides/getting-started.md)

## Índice de documentación

| Categoría | Ruta | Descripción |
| ---------- | ------ | ------------- |
| **Arquitectura** | | |
| Clean Architecture | [es/architecture/overview.md](es/architecture/overview.md) | Estructura de capas, flujo de dependencias, mapeo de carpetas |
| **Dominio** | | |
| Catálogo de entidades | [es/domain/entities.md](es/domain/entities.md) | 9 entidades con def... |
| **Funcionalidades** | | |
| Auth | [../../lib/features/auth/](../../lib/features/auth/) | Login, registro, gestión de sesión |
| Books | [../../lib/features/books/](../../lib/features/books/) | CRUD de libros, carga de portada, visibilidad |
| Chapters | [../../lib/features/chapters/](../../lib/features/chapters/) | Lectura de capítulos, almacenamiento de contenido |
| Tooks | [../../lib/features/tooks/](../../lib/features/tooks/) | Volúmenes/tomos dentro de libros |
| Genres | [../../lib/features/genres/](../../lib/features/genres/) | Clasificación por géneros |
| Labels | [../../lib/features/labels/](../../lib/features/labels/) | Sistema de etiquetado |
| Label Rules | [../../lib/features/label_rules/](../../lib/features/label_rules/) | Reglas automáticas de asignación de etiquetas, gestionadas por admin |
| Profiles | [../../lib/features/profiles/](../../lib/features/profiles/) | Perfiles de usuario, gestión de roles |
| Favorites | [../../lib/features/favorites/](../../lib/features/favorites/) | Favoritos de libros |
| Admin | [../../lib/features/admin/](../../lib/features/admin/) | Panel de administración |
| Scan | [../../lib/features/scan/](../../lib/features/scan/) | Creación de contenido |
| App | [../../lib/features/app/](../../lib/features/app/) | Shell, routing, drawer (NavigationDrawer con AppDrawerHeader, DrawerSectionLabel, LogoutFooter, menús por rol), secciones de pantalla principal (carrusel, continuar leyendo, novedades, más vistos, populares, géneros) |
| **Tipos de usuario** | | |
| Usuario regular | [es/user-types/regular-user.md](es/user-types/regular-user.md) | Rol por defecto |
| Usuario Scan | [es/user-types/scan-user.md](es/user-types/scan-user.md) | Rol de creador de contenido |
| Usuario Admin | [es/user-types/admin-user.md](es/user-types/admin-user.md) | Rol de acceso completo |
| **Base de datos** | | |
| Docs de BD | [es/database/README.md](es/database/README.md) | Tablas, storage, RLS, funciones SQL |
| **Guías** | | |
| Inicio rápido | [es/guides/getting-started.md](es/guides/getting-started.md) | Guía de configuración para desarrolladores |
| **Testing** | | |
| Estrategia de tests | [es/testing/README.md](es/testing/README.md) | 55 archivos de test, categorías, patrones |

## Estructura del proyecto

```text
lib/
├── core/              # Transversal: DI, errores, cliente Supabase, tema, utils
├── features/          # 12 módulos de funcionalidad (domain/data/presentation c/u)
│   ├── admin/
│   ├── app/
│   ├── auth/
│   ├── books/
│   ├── chapters/
│   ├── favorites/
│   ├── genres/
│   ├── labels/
│   ├── label_rules/
│   ├── profiles/
│   ├── scan/
│   └── tooks/
├── shared/            # Entidades y widgets compartidos entre funcionalidades
│   ├── domain/
│   └── presentation/
└── main.dart          # Punto de entrada
```text

---

> Última verificación: 2026-07-23
