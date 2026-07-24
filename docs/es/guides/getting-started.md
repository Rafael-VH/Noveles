# Primeros pasos

> Guía paso a paso para clonar, configurar y ejecutar el proyecto Noveles
> localmente.

← [Volver al índice](../README.md)

## Requisitos previos

| Requisito | Versión | Notas |
| ------------- | --------- | ------- |
| Flutter SDK | >=3.3.4 | Ejecutá `flutter --version` para verificar |
| Dart SDK | (incluido con Flutter) | |
| Cuenta de Supabase | El plan gratuito alcanza | [supabase.com](https://supabase.com) |
| IDE | VS Code o Android Studio | Se recomiendan extensiones de Flutter/Dart |
| Android Studio / Xcode | Última versión | Para emulador/simulador |

## Clonar e instalar

```bash
git clone https://github.com/<owner>/Noveles.git
cd Noveles
flutter pub get
```text

## Configuración del entorno

Noveles usa `flutter_dotenv` para la configuración. Creá un archivo `.env`
en la raíz del proyecto:

```bash
cp .env.example .env
```text

> **Nota**: `.env.example` aún no existe. Creá `.env` manualmente con el
siguiente contenido:

```text
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
```text

**Dónde encontrar estos valores:**

1. Andá al [Panel de Supabase](https://supabase.com/dashboard)
2. Seleccioná tu proyecto
3. Andá a **Settings → API**
4. Copiá la **Project URL** y la clave **anon public**

### Seguridad

El archivo `.env` está listado en los assets de `pubspec.yaml` (necesario
para que `flutter_dotenv` lo cargue) y debería estar en `.gitignore`.
**Nunca subas tu archivo `.env`** con credenciales reales.

## Configuración de Supabase

Si tenés una instancia local de Supabase:

```bash
supabase db push
```text

Esto ejecuta todas las migraciones y configura el esquema de la base de
datos (tablas, políticas RLS, buckets de storage).

Para un proyecto remoto de Supabase, las migraciones se aplican mediante
el panel o CI/CD.

## Ejecutar la app

```bash
flutter run
```text

Asegurate de tener un dispositivo o emulador conectado. Para web:

```bash
flutter run -d chrome
```text

## Estructura del proyecto

```text
lib/
├── main.dart              # Punto de entrada: dotenv → Supabase → DI → App
├── core/                  # Concerns transversales
│   ├── app/               # Widget App, routing
│   ├── di/                # Inyección de dependencias con GetIt (11 módulos)
│   ├── errors/            # `Result<T>`, tipos de Failure
│   ├── supabase/          # Proveedor de cliente, caché de capítulos
│   ├── constants/         # StorageConstants
│   ├── presentation/      # ThemeBloc, notificaciones, widgets compartidos
│   └── utils/             # Colores, tema, parsing, logging
├── features/              # 10 módulos de funcionalidad
│   ├── auth/              # Autenticación (login, registro)
│   ├── books/             # CRUD, visualización y favoritos de libros
│   ├── chapters/          # Lectura de capítulos
│   ├── tooks/             # Volúmenes/tomos
│   ├── genres/            # Clasificación por géneros
│   ├── labels/            # Sistema de etiquetado (incluye reglas de etiquetas)
│   ├── profiles/          # Perfiles de usuario
│   ├── admin/             # Panel de administración
│   ├── scan/              # Creación de contenido
│   └── app/               # Shell (MainScreen, drawer)
└── shared/                # Código entre funcionalidades
    ├── domain/entities/   # BookWithRelations
    └── presentation/      # Widgets compartidos
```text

Cada módulo de funcionalidad sigue Clean Architecture:

```text
features/{feature}/
├── di/           # Registro de DI específico de la funcionalidad
├── domain/       # Entidades, casos de uso, interfaces de repositorio
├── data/         # Implementaciones de repositorio (Supabase)
└── presentation/ # BLoCs, pantallas, widgets
```text

## Ejecutar tests

```bash
# Ejecutá todos los tests
flutter test

# Ejecutá con reporte de cobertura
flutter test --coverage

# Ejecutá un archivo de test específico
flutter test test/bloc/auth_bloc_test.dart
```text

La estructura de tests refleja la carpeta `lib/`: `test/bloc/`,
`test/entities/`, `test/repositories/`, `test/use_cases/`,
`test/widgets/`.

## Problemas comunes

| Problema | Solución |
| --------- | ---------- |
| `Missing .env file` | Creá `.env` con SUPABASE_URL y SUPABASE_ANON_KEY |
| `Supabase connection error` | Verificá que tu URL y anon key sean correctos |
| `flutter pub get` falla | Ejecutá `flutter clean && flutter pub get` |
| Emulador no encontrado | Abrí Android Studio → Device Manager e iniciá uno |

---

> Última verificación: 2026-07-21
