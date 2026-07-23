# Despliegue

> Compilá y desplegá Noveles en Android, Web e iOS — con configuración de
> producción para Supabase.

## Android

### APK de depuración

```bash
flutter build apk --debug
```text

Salida: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de lanzamiento

```bash
flutter build apk --release
```text

Salida: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle de lanzamiento (Play Store)

```bash
flutter build appbundle --release
```text

Salida: `build/app/outputs/bundle/release/app-release.aab`

**Firmado**: Configurá `android/app/build.gradle` con tu keystore para
compilaciones de lanzamiento.

## Web

```bash
flutter build web --release
```text

Salida: `build/web/`

Servilo con cualquier servidor de archivos estáticos. Para Supabase en
web, asegurate de que las URLs de redirección de auth de tu proyecto
incluyan tu dominio de despliegue.

**Notas**:

- Las compilaciones web requieren configuración CORS adecuada en Supabase
- `flutter_native_splash` no se usa en web
- `image_picker` puede tener funcionalidad limitada en web

## iOS

```bash
flutter build ipa --release
```text

Salida: `build/ios/ipa/`

**Requisitos**:

- Xcode con un certificado de firmado válido
- Configurá el bundle identifier en `ios/Runner.xcodeproj`
- Configurá los perfiles de aprovisionamiento para distribución

## Configuración de producción en Supabase

### Base de datos

```bash
supabase db push
```text

Aplica todas las migraciones de `supabase/migrations/` a la base de datos
remota.

### Buckets de Storage

Verificá que estos buckets existan en tu panel de Supabase:

| Bucket | Propósito | Público |
| -------- | --------- | -------- |
| `covers` | Imágenes de portada de libros/tomos | Sí |
| `chapters` | Archivos de contenido de capítulos (.md, .txt) | No |
| `avatars` | Fotos de perfil de usuario | Sí |

### Funciones RPC

Desplegá las funciones SQL usadas por la funcionalidad de analíticas:

- `get_views_trend(days_back)` — datos de tendencia de vistas
- `get_top_books(limit_count)` — libros más vistos
- `get_analytics_overview` — resumen del panel

Mirá `docs/es/database/sql-functions.md` para las definiciones de
funciones.

### Políticas RLS

Asegurate de que las políticas de seguridad a nivel de fila (RLS) estén
activas en todas las tablas. Mirá `docs/es/database/rls-policies.md` para
la lista completa de políticas.

## Variables de entorno

Creá un archivo `.env` de producción en la raíz del proyecto:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```text

**Seguridad**: Nunca subas `.env` al control de versiones. El `.gitignore`
ya lo excluye.

## Versionado de compilaciones

Actualizá la versión en `pubspec.yaml` antes de cada lanzamiento:

```yaml
version: 1.1.0+1  # version+build_number
```text

El número de compilación se auto-incrementa para Android; para iOS,
configuralo explícitamente en Xcode.

## Relacionados

- [Primeros pasos](./getting-started.md) — Configuración de
  desarrollo local
- [Entorno](../configuration/environment.md) — Variables de entorno
- [Dependencias](../configuration/dependencies.md) — Versiones de
  paquetes
- [Base de datos](../database/README.md) — Esquema y migraciones

← Volver al [índice](../README.md)
