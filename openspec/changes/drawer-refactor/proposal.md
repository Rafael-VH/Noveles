# Proposal: drawer-refactor

## Intent

Rediseñar visualmente el menú lateral (`AppDrawer`) para que sea moderno, agradable y consistente para los 3 roles del sistema. Reemplazar el actual `Drawer` + `ListView` + `ListTile` plano por un `NavigationDrawer` M3 con diseño por secciones, header con gradiente, avatar de mayor tamaño, indicador de selección tipo pill redondeado, y tipografía cuidada. Como parte del cambio, reemplazar los boolean props (`isAdmin`, `isScan`) por un solo `UserRole?`, extraer el header a su propio widget, agregar `NavigationDrawerThemeData` a ambos temas, y manejar el estado no autenticado mostrando una opción de login.

## Current navigation structure per role

### reader (`UserRole.user`)
```
Drawer
├── DrawerHeader (avatar, displayName, email)
├── ListTile "Inicio" (home) → pop drawer
├── ListTile "Editar Perfil" (person) → ProfileScreen
├── ListTile "Mis Favoritos" (favorite) → FavoritesScreen
├── Divider
└── ListTile "Cerrar Sesión" (logout, error color) → confirm → LogoutRequested
```

### scan (`UserRole.scan`)
```
Drawer
├── DrawerHeader (avatar, displayName, email)
├── ListTile "Panel Scan" (admin_panel_settings) → pop drawer
├── ListTile "Editar Perfil" (person) → ProfileScreen
├── ListTile "Mis Favoritos" (favorite) → FavoritesScreen
├── ListTile "Etiquetas" (label) → LabelManagementScreen
├── Divider
└── ListTile "Cerrar Sesión" (logout, error color) → confirm → LogoutRequested
```

### admin (`UserRole.admin`)
```
Drawer
├── DrawerHeader (avatar, displayName, email)
├── ListTile "Panel Admin" (admin_panel_settings) → /admin route
├── ListTile "Editar Perfil" (person) → ProfileScreen
├── ListTile "Mis Favoritos" (favorite) → FavoritesScreen
├── Divider
└── ListTile "Cerrar Sesión" (logout, error color) → confirm → LogoutRequested
```

### unauthenticated
```
Drawer → SizedBox.shrink()  ← vacío, sin opción de login
```

## Proposed visual design

### Visual structure (shared across roles)

```
┌──────────────────────────────┐
│  AppDrawerHeader             │  ← fondo con gradiente primario → primaryContainer
│  ┌──────────────────┐        │     con sombra sutil
│  │   Avatar (48px)  │        │  ← CircleAvatar más grande que hoy (32px)
│  └──────────────────┘        │
│  Nombre del Usuario          │  ← titleLarge, blanco/contrastante
│  email@ejemplo.com           │  ← bodySmall, opacidad 80%
├──────────────────────────────┤  ← Divider sutil
│  Navegación                  │  ← Section label (labelSmall, uppercase, spacing)
│  ┌────────────────────────┐  │
│  │ 🔷  Item de menú       │  │  ← NavigationDrawerDestination
│  └────────────────────────┘  │     con pill indicator redondeado (radius 12)
│  ┌────────────────────────┐  │
│  │ 🔷  Otro item          │  │
│  └────────────────────────┘  │
├──────────────────────────────┤  ← Divider sutil (menos opaco)
│  Perfil                      │  ← Section label
│  ┌────────────────────────┐  │
│  │ 🔷  Editar Perfil      │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🔷  Mis Favoritos      │  │  ← solo reader
│  └────────────────────────┘  │
│           ...                │
├──────────────────────────────┤  ← Espaciador flexible
│  ┌────────────────────────┐  │
│  │ 🚪  Cerrar Sesión      │  │  ← LogoutFooter, color error
│  └────────────────────────┘  │
└──────────────────────────────┘
```

### reader (`UserRole.user`)
```
NavigationDrawer
├── AppDrawerHeader (gradient bg, avatar 48px, name, email)
│
├── SectionLabel "Navegación"
├── NavigationDrawerDestination (home, "Inicio")
│
├── SectionLabel "Perfil"
├── NavigationDrawerDestination (person, "Editar Perfil")
├── NavigationDrawerDestination (favorite, "Mis Favoritos")
│
├── Spacer
└── LogoutFooter (logout, "Cerrar Sesión", error color)
```

### scan (`UserRole.scan`)
```
NavigationDrawer
├── AppDrawerHeader (gradient bg, avatar 48px, name, email)
│
├── SectionLabel "Navegación"
├── NavigationDrawerDestination (qr_code_scanner, "Panel Scan")
│
├── SectionLabel "Perfil"
├── NavigationDrawerDestination (person, "Editar Perfil")
│
├── SectionLabel "Gestión"
├── NavigationDrawerDestination (label, "Etiquetas")
│
├── Spacer
└── LogoutFooter (logout, "Cerrar Sesión", error color)
```

### admin (`UserRole.admin`)
```
NavigationDrawer
├── AppDrawerHeader (gradient bg, avatar 48px, name, email)
│
├── SectionLabel "Navegación"
├── NavigationDrawerDestination (admin_panel_settings, "Panel Admin")
│
├── SectionLabel "Perfil"
├── NavigationDrawerDestination (person, "Editar Perfil")
│
├── Spacer
└── LogoutFooter (logout, "Cerrar Sesión", error color)
```

### unauthenticated — NUEVO
```
NavigationDrawer
├── AppDrawerHeader (simplified — logo Noveles en tonos grises)
│
├── NavigationDrawerDestination (login, "Iniciar Sesión")
│
└── (sin logout)
```

## Items por rol (resumen)

| Item | reader | scan | admin |
|------|--------|------|-------|
| Inicio | ✅ | — | — |
| Panel Scan | — | ✅ | — |
| Panel Admin | — | — | ✅ |
| Editar Perfil | ✅ | ✅ | ✅ |
| Mis Favoritos | ✅ | — | — |
| Etiquetas | — | ✅ | — |
| Cerrar Sesión | ✅ | ✅ | ✅ |

## Visual design decisions

| Decisión | Detalle |
|----------|---------|
| Header con gradiente | `primary` → `primaryContainer` con `Container(decoration: BoxDecoration(gradient: ...))` en vez de color sólido |
| Avatar de 48px | De 32px → 48px para mejor presencia visual |
| Texto contrastante | Nombre en `titleLarge` color `onPrimary`, email en `bodySmall` con 80% opacidad |
| Section labels | `Text("Sección", style: labelSmall.copyWith(color: onSurfaceVariant))` con padding vertical |
| Pill indicator | `indicatorShape: RoundedRectangleBorder(radius: 12)` para selección suave |
| Espaciado generoso | `tileHeight: 56`, padding consistente |
| Logout siempre al fondo | `Spacer` + `LogoutFooter` con `Divider` sutil encima |
| Sombra en header | `BoxShadow` sutil o `elevation: 2` en el Container del header |

## Key architectural decisions

| Decision | Rationale |
|----------|-----------|
| `NavigationDrawer` en vez de `Drawer` | M3 built-in, zero deps, mismo sistema de diseño |
| `NavigationDrawerDestination` en vez de `ListTile` | M3-native destination, styled via theme |
| `UserRole?` en vez de `bool isAdmin` + `bool isScan` | Enum ya existe, elimina estados inválidos |
| `AppDrawerHeader` extraído | Header con gradiente, avatar, nombre, email; reusable |
| `LogoutFooter` como widget separado | Logout no es un destination, va al fondo con estilo propio |
| `NavigationDrawerThemeData` en themes | Mismo patrón que `NavigationBarThemeData` ya existente |
| Reusar `ConfirmationDialog` | Ya existe en `shared/presentation/widgets/`, elimina duplicación |

## Architecture check

**NavigationDrawer es la decisión correcta**: Widget M3 built-in (`package:flutter/material.dart`), sin dependencias externas. El proyecto ya usa `useMaterial3: true` y otros M3 components (`NavigationBar`, `NavigationBarThemeData`). Es el sucesor M3 de `Drawer` para menús de navegación.

## Scope

| Archivo | Acción | Líneas |
|---------|--------|--------|
| `lib/features/app/presentation/widgets/drawer/app_drawer_header.dart` | **Crear** | ~60 |
| `lib/features/app/presentation/widgets/drawer/drawer_section_label.dart` | **Crear** | ~15 |
| `lib/features/app/presentation/widgets/drawer/logout_footer.dart` | **Crear** | ~40 |
| `lib/features/app/presentation/widgets/app_drawer.dart` | Reescribir | ~180 |
| `lib/core/utils/theme/light_theme.dart` | +`navigationDrawerTheme` | +15 |
| `lib/core/utils/theme/dark_theme.dart` | +`navigationDrawerTheme` | +15 |
| `lib/features/app/presentation/screens/main_screen.dart` | Cambiar props | ~5 |
| `lib/features/admin/presentation/screens/admin_dash_screen.dart` | Cambiar props | ~5 |
| `lib/features/scan/presentation/screens/scan_main_screen.dart` | Cambiar props | ~2 |
