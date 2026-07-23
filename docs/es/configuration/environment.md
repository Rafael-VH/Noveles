# Configuración de entorno

> Variables de entorno requeridas y configuración para la integración con
> Supabase.

## Variables requeridas

| Variable | Propósito | Ejemplo |
| ---------- | --------- | --------- |
| `SUPABASE_URL` | URL proyecto Supabase | `https://xyzcompany.supabase.co` |
| `SUPABASE_ANON_KEY` | Clave anónima de Supabase | eyJhbGciOiJIUzI1NiIs... |

## Configuración

1. **Creá el archivo `.env`** en la raíz del proyecto:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```text

1. **Cargalo en `main.dart`** usando `flutter_dotenv`:

```dart
await dotenv.load(fileName: '.env');
```text

1. **Inicializá Supabase** con las variables de entorno:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```text

**Fuente**: `lib/main.dart`

## Seguridad

- `.env` está en `.gitignore` — nunca subas secretos al control de
  versiones
- Usá `.env.example` como plantilla (subí este archivo)
- El operador `!` en `dotenv.env['VAR']!` significa que la app fallará si
  faltan variables — esto es intencional para detectar mala configuración
  temprano
- La clave anónima de Supabase es segura para uso del lado del cliente
  (las políticas RLS controlan el acceso a los datos)

## Problemas comunes

| Problema | Causa | Solución |
| ------- | ------- | ---------- |
| dotenv.env['SUPABASE_URL'] null | .env faltante | .env en raíz del proyecto |
| SupabaseException al iniciar | URL o clave inválida | Verificá credenciales |
| .env subido a git | Olvidaste .gitignore | Eliminalo del seguimient... |

← Volver al [índice](../README.md)
