# Tema

> Soporte de tema claro/oscuro mediante ThemeBloc con tokens de diseño de
> Material 3.

## Resumen

Noveles soporta temas claro y oscuro usando Material 3 (`useMaterial3: true`).
El tema por defecto es **modo oscuro**. El cambio de tema lo maneja `ThemeBloc`
y se aplica a nivel de `MaterialApp` mediante `BlocBuilder<ThemeBloc, ThemeState>`.

## ThemeBloc

**Archivo**: `lib/core/presentation/bloc/theme_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `ThemeChanged` | Cambiar entre modo claro y oscuro |

| Estado | Datos | Cuándo |
| ------ | ----- | ------ |
| ThemeState | `bool isDarkMode, ThemeData themeData` | Siempre (estado único) |

- Por defecto: `isDarkMode: true`, `DarkTheme.darkTheme`
- Sin persistencia — el tema vuelve a oscuro al reiniciar la app

**Eventos**: `lib/core/presentation/bloc/theme_event.dart` — `ThemeChanged(bool
isDarkMode)`

**Estado**: `lib/core/presentation/bloc/theme_state.dart` — contiene tanto la
bandera como el `ThemeData` resuelto

## Archivos de Tema

| Archivo | Clase | Propósito |
| ------- | ----- | --------- |
| `lib/core/utils/theme/dark_theme.dart` | `DarkTheme` | Tema oscuro |
| `light_theme.dart` | `LightTheme` | Definición del tema claro |
| `lib/core/utils/theme/theme.dart` | — | Exportación barrel para ambos |

## Sistema de Colores

Ambos temas comparten la misma estructura de colores con diferentes valores:

| Token | Oscuro | Claro | Uso |
| ----- | ------ | ----- | --- |
| Primary | `#71A202` | `#71A202` | Verde acento (misma marca) |
| Secondary | `#6B6B80` | `#6B6B80` | Gris-lavanda apagado |
| Tertiary | `#3E9A7A` | `#3E9A7A` | Verde azulado suave |
| Background | Superficie oscura | `#F8F8FC` | Fondo de pantalla |
| Surface | Tarjetas elevadas | `#FFFFFF` | Fondos de tarjetas |
| Error | `#B3261E` | `#B3261E` | Estados de error |

El tema oscuro usa constantes `DarkColor`; el tema claro usa constantes privadas
`_LightColor`.

## Tema de Texto

Ambos temas definen un `TextTheme` completo con 15 estilos:

| Categoría | Estilos | Uso |
| --------- | ------- | --- |
| Display | `Large`, `Medium`, `Small` | Splash, texto heroico |
| Headline | `Large`, `Medium`, `Small` | Títulos de pantalla |
| Title | `Large`, `Medium`, `Small` | Títulos de tarjetas, encabezados |
| Body | `Large`, `Medium`, `Small` | Contenido de lectura, descripciones |
| Label | `Large`, `Medium`, `Small` | Botones, chips, pestañas |

Los pesos de fuente van desde `w300` (display large) hasta `w600` (headlines,
titles, labels).

## Personalización

Ambos temas personalizan todos los temas de componentes de Material 3:
`AppBarTheme`, `CardThemeData`, `ElevatedButtonThemeData`,
`InputDecorationTheme`, `DialogThemeData`, `BottomSheetThemeData`,
`SnackBarThemeData`, `ChipThemeData`, `SwitchThemeData`,
`FloatingActionButtonThemeData` y más. Las transiciones de página usan
`CupertinoPageTransitionsBuilder` en ambas plataformas.

## Relacionados

- [App Feature](../features/app/README.md) — Proveedor de ThemeBloc en App
- [Routing](./routing.md) — ThemeBloc en MaterialApp.builder

← Volver al [índice](../README.md)
