# Dependencias

> Dependencias de ejecución y desarrollo — visión general categorizada de
> todos los paquetes usados.

## Visión general

Noveles usa 14 dependencias de ejecución y 3 de desarrollo. Todas se
gestionan mediante `pubspec.yaml` con restricciones de versión. El
proyecto apunta a Dart SDK `>=3.3.4 <4.0.0`.

## Dependencias de ejecución

| Categoría | Paquete | Versión | Propósito |
| ---------- | --------- | --------- | --------- |
| **Manejo de estado** | | | |
| | `bloc` | `^8.1.4` | Núcleo del patrón BLoC |
| | `flutter_bloc` | `^8.1.6` | Widgets BLoC para Flutter |
| | `equatable` | `^2.0.5` | Igualdad por valor para estados/eventos |
| **Backend** | | | |
| | `supabase_flutter` | `^2.10.0` | Cliente Supabase (Auth, DB, Storage) |
| **Inyección de dependencias** | | | |
| | `get_it` | `^7.6.0` | Service locator / contenedor DI |
| **UI** | | | |
| | `carousel_slider` | `^5.1.2` | Carrusel de libros en pantalla de inicio |
| | `cached_network_image` | `^3.4.1` | Caché de portadas y avatares |
| **Selectores de archivos** | | | |
| | `image_picker` | `^1.1.2` | Selección de imágenes desde cámara/galería |
| | `file_picker` | `^8.0.0` | Selección genérica de archivos (.md, .txt) |
| | `path_provider` | `^2.1.4` | Rutas de archivo específicas de plataforma |
| **Configuración** | | | |
| | `flutter_dotenv` | `^6.0.1` | Carga de variables de entorno desde `.env` |
| **UX** | | | |
| | `flutter_native_splash` | `^2.4.1` | Configuración de splash nativa |
| | `url_launcher` | `^6.3.1` | Abrir URLs externas |

**Total**: 14 dependencias de ejecución

## Dependencias de desarrollo

| Paquete | Versión | Propósito |
| --------- | --------- | --------- |
| `flutter_test` | SDK | Tests unitarios y de widgets |
| `flutter_lints` | `^5.0.0` | Reglas de lint |
| `mocktail` | `^1.0.4` | Objetos mock para testing |
| `bloc_test` | `^9.1.7` | Helpers de test específicos para BLoC |

## Entorno

La app carga variables de entorno mediante `flutter_dotenv`:

```yaml
flutter:
  assets:
    - .env
```text

Variables de entorno requeridas (mirá
`docs/es/configuration/environment.md`):

- `SUPABASE_URL` — URL del proyecto Supabase
- `SUPABASE_ANON_KEY` — Clave anónima de la API de Supabase

## Relacionados

- [Primeros pasos](../guides/getting-started.md) — Instrucciones de
  configuración
- [Entorno](./environment.md) — Configuración de `.env`
- [Despliegue](../guides/deployment.md) — Instrucciones de compilación
- [Testing](../testing/README.md) — Configuración de tests con
  mocktail/bloc_test

← Volver al [índice](../README.md)
