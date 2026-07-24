# 📖 Noveles

**Una plataforma de lectura de novelas multirrol** — leé, creá y gestioná
novelas con acceso basado en roles, construida con Flutter + Supabase.

[![Flutter](https://img.shields.io/badge/Flutter-3.3%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Tests](https://img.shields.io/badge/tests-471-passing-brightgreen)](es/testing/README.md)

---

**🌐 Idioma / Language**: [🇬🇧 English](../../README.md)

> 📚 [Documentación completa](es/README.md)

---

## 🎯 ¿Qué es Noveles?

Noveles es una aplicación móvil completa para leer y gestionar novelas
digitales. Soporta **tres roles de usuario** — cada uno con una experiencia
adaptada:

| Rol | Experiencia |
| :--- | :--- |
| **👤 Lector** | Navegá, leé, seguí tu progreso, gestioná favoritos |
| **✍️ Scan** | Creá y gestioná libros, tomos y capítulos |
| **🛡️ Admin** | Analíticas, usuarios, géneros y etiquetas |

> Los usuarios suspendidos son bloqueados a nivel de auth — sin acceso a
> ninguna pantalla.

## ✨ Funcionalidades

### 📚 Para lectores

- **Feed inteligente en inicio** — carrusel de libros destacados,
  "Continuar leyendo" (lecturas recientes), novedades, más vistos,
  populares y navegación por género
- **Scroll infinito** — lista de libros paginada que carga al hacer scroll
- **Seguimiento de lectura** — capítulos marcados como leídos, indicadores
  visuales en la lista de tomos
- **Favoritos** — lista personal de libros con un toque para alternar
- **Menú lateral basado en rol** — M3 NavigationDrawer con secciones
  adaptadas a tu rol
- **Tema claro/oscuro** — alterná entre modos (oscuro por defecto)

### 🖋️ Para creadores (Scan)

- **CRUD completo de libros** — creá, editá, eliminá libros con carga de
  imagen de portada
- **Gestión de tomos** — organizá libros en tomos con sus propias portadas
- **Editor de capítulos** — edición de contenido inline o carga de archivos
  (.md, .txt)
- **Sistema de etiquetas** — creá etiquetas con códigos de color y
  asignalas a libros

### 🛠️ Para admins

- **Panel de analíticas** — visualizá tendencias, libros top y estadísticas
  generales con datos diarios
- **Gestión de usuarios** — cambiá roles (user/scan/admin), suspendé o
  reactivá cuentas
- **Supervisión de libros** — alterná visibilidad, eliminá contenido
  inapropiado
- **Gestión de géneros y etiquetas** — CRUD completo de metadatos
- **Reglas de etiquetado automático** — configurá reglas que asignan
  etiquetas automáticamente según datos del libro (nuevos lanzamientos,
  más leídos, más populares, más favoritados)

## 🏗️ Arquitectura de un vistazo

```text
┌─────────────────────────────────┐
│       Presentation              │  BLoCs, Screens, Widgets
├─────────────────────────────────┤
│         Domain                  │  Entities, Use Cases, Repository interfaces
├─────────────────────────────────┤
│           Data                  │  Repository implementations, Supabase
└─────────────────────────────────┘
```

**Arquitectura Limpia** con tres capas. La capa de dominio es **Dart puro**
— sin imports de Flutter ni Supabase. Esto hace que las entidades y casos
de uso sean testeables sin dependencia de framework.

### Stack tecnológico

| Capa | Tecnología |
| :--- | :--- |
| **Frontend** | Flutter 3.3+ / Dart 3.3+ |
| **Manejo de estado** | BLoC + Cubit |
| **Inyección de dependencias** | GetIt (service locator) |
| **Backend** | Supabase (Postgres, Auth, Storage, Edge Functions) |
| **Testing** | flutter_test, mocktail, bloc_test |

### Estructura del proyecto

```text
lib/
├── core/              # Transversal: DI, errores, cliente Supabase, tema, utils
├── features/          # 10 módulos de funcionalidad (domain/data/presentation c/u)
│   ├── admin/         # Panel, analíticas, gestión de usuarios
│   ├── app/           # Shell, routing, NavigationDrawer, pantalla de inicio
│   ├── auth/          # Login, registro, gestión de sesión
│   ├── books/         # CRUD de libros, paginación, seguimiento de vistas, favoritos
│   ├── chapters/      # Lectura de capítulos, gestión de contenido
│   ├── genres/        # Clasificación por géneros
│   ├── labels/        # Etiquetas manuales con código de color + reglas automáticas
│   ├── profiles/      # Perfiles de usuario, gestión de roles
│   ├── scan/          # Panel de creación de contenido
│   └── tooks/         # Volúmenes/tomos dentro de libros
├── shared/            # Entidades y widgets compartidos
└── main.dart
```

## 🧪 Testing

**471 tests y sumando** en todas las capas:

| Categoría | Cantidad | Lo que cubre |
| :--- | :--- | :--- |
| Tests BLoC | 16 | Todos los BLoCs: transiciones y manejo de eventos |
| Tests de Entidades | 5 | Construcción, igualdad, copyWith |
| Tests de Repositorios | 9 | Queries a Supabase, mapeo de errores |
| Tests de Casos de Uso | 7 | Lógica de negocio, Result |
| Tests de Widgets | 26 | Renderizado UI, interacciones y menús por rol |
| **Total** | **471** | |

```bash
flutter test        # Ejecutá todos los tests
flutter test --coverage   # Con reporte de cobertura
```

## 🚀 Inicio rápido

```bash
# Requisitos: Flutter 3.3+, cuenta de Supabase
git clone https://github.com/<your-org>/Noveles.git
cd Noveles
flutter pub get
```

Creá un archivo `.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Ejecutá las migraciones:

```bash
supabase db push
```

Ejecutá la app:

```bash
flutter run
```

> Guía completa de configuración →
> [docs/es/guides/getting-started.md](docs/es/guides/getting-started.md)

## 📚 Documentación

| Categoría | Ruta | Cubre |
| :--- | :--- | :--- |
| **Arquitectura** | [docs/es/architecture/overview.md](docs/es/architecture/overview.md) | Capas de Clean Architecture, flujo de dependencias |
| **Routing** | [docs/es/architecture/routing.md](docs/es/architecture/routing.md) | Selección de inicio según rol, guardia de auth |
| **Tema** | [docs/es/architecture/theme.md](docs/es/architecture/theme.md) | Tema M3 claro/oscuro, tema de NavigationDrawer |
| **Base de datos** | [docs/es/database/README.md](docs/es/database/README.md) | 13 tablas, 35 migraciones, políticas RLS |
| **Entidades** | [docs/es/domain/entities.md](docs/es/domain/entities.md) | Las 10 entidades de dominio con definiciones de campos |
| **Casos de uso** | [docs/es/domain/use-cases.md](docs/es/domain/use-cases.md) | 54 casos de uso en todas las funcionalidades |
| **Tipos de usuario** | [docs/es/user-types/](docs/es/user-types/) | Permisos por rol (admin, scan, user, suspended) |
| **Testing** | [docs/es/testing/README.md](docs/es/testing/README.md) | Estrategia de tests, patrones, brechas de cobertura |

## 🗺️ Routing basado en rol

La app selecciona la pantalla de inicio adecuada según el rol del usuario
autenticado:

```text
AuthAuthenticated
├── isAdmin    → AdminDashScreen  (gestión completa)
├── isScan     → ScanMainScreen   (creación de contenido)
├── isUser     → MainScreen       (experiencia de lectura)
└── else       → LoginScreen      (suspendido / desconocido)
```

Rutas nombradas:

- `/admin` — panel de admin
- `/label-management` — gestión de etiquetas (scan + admin)

El resto de la navegación es imperativa mediante `Navigator.push`.

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! El proyecto sigue Clean Architecture
con reglas estrictas de dependencia:

1. **La capa de dominio** debe tener cero imports de framework (Dart puro)
2. **Las funcionalidades** se organizan en tres capas: `domain/`, `data/`,
   `presentation/`
3. **Todos los casos de uso** retornan `Result<T>` — sin excepciones para
   flujo de control
4. **Se esperan tests** para BLoCs, entidades y repositorios

Mirá la [visión general de arquitectura](docs/es/architecture/overview.md)
completa antes de contribuir.

## 📄 Licencia

Este proyecto es privado. Todos los derechos reservados.

---

Hecho con ❤️ usando Flutter & Supabase
