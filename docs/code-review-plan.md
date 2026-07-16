# Plan de Correcciones: Noveles Flutter App

## Contexto

Después de revisar la arquitectura limpia del proyecto (`lib/core`, `lib/features`), identificamos **12 issues** organizados en 4 niveles de prioridad. Este documento detalla los cambios necesarios para cada uno.

---

## Resumen de Issues por Prioridad

| Prioridad | Cantidad | Tipo de Impacto |
|-----------|----------|-----------------|
| **P0** | 3 | Crash garantizados en ciertos flujos |
| **P1** | 4 | Memory leaks, data loss, poor UX |
| **P2** | 3 | UX improvements |
| **P3** | 2 | Code quality |

---

## P0: Critical - Correcciones Inmediatas

### P0-1: Null Safety en CoverUrlService

**Archivo:** `lib/core/cover/cover_url_service.dart`

**Problema:** Si `cover` es `null`, lanza `NoSuchMethodError`.

**Cambio:**

```dart
// ANTES (línea 8-12)
String call(String cover) {
  if (cover.isEmpty) return '';
  if (cover.startsWith('http')) return cover;
  return _supabase.storage.from('covers').getPublicUrl(cover);
}

// DESPUÉS
String call(String? cover) {
  if (cover == null || cover.isEmpty) return '';
  if (cover.startsWith('http')) return cover;
  return _supabase.storage.from('covers').getPublicUrl(cover);
}
```

---

### P0-2: Crash en AppDrawer con avatarUrl

**Archivo:** `lib/features/presentation/widgets/app_drawer.dart`

**Problema:** `CoverUrlService.call()` recibe `String` pero `user.avatarUrl` puede ser `null`.

**Cambio (línea 34-42):**

```dart
// ANTES
CircleAvatar(
  radius: 32,
  backgroundImage:
      user.avatarUrl != null && user.avatarUrl!.isNotEmpty
          ? NetworkImage(getIt<CoverUrlService>()(user.avatarUrl!))
          : null,
  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
      ? const Icon(Icons.person, size: 32)
      : null,
),

// DESPUÉS
CircleAvatar(
  radius: 32,
  backgroundImage: (user.avatarUrl?.isNotEmpty ?? false)
      ? NetworkImage(getIt<CoverUrlService>()(user.avatarUrl!))
      : null,
  child: (user.avatarUrl?.isEmpty ?? true)
      ? const Icon(Icons.person, size: 32)
      : null,
),
```

**Nota:** Con P0-1 corregido (nullable `String?`), este código es seguro. Si prefieres mantenerlo defensivo, usa el código de arriba.

---

### P0-3: ANR en ChapterBloc - N+1 Queries

**Archivo:** `lib/features/presentation/bloc/chapter/chapter_bloc.dart`

**Problema:** Loop secuencial hace N queries, congelando la UI.

**Cambio completo del archivo:**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noveles/core/errors/result.dart';
import 'package:noveles/core/presentation/notification_service.dart';
import 'package:noveles/features/chapters/domain/chapter_entity.dart';
import 'package:noveles/features/chapters/domain/get_chapter_content.dart';
import 'package:noveles/features/presentation/bloc/chapter/chapter_event.dart';
import 'package:noveles/features/presentation/bloc/chapter/chapter_state.dart';

class ChapterBloc extends Bloc<ChapterEvent, ChapterState> {
  final GetChapterContent getChapterContent;

  ChapterBloc({required this.getChapterContent}) : super(ChapterInitial()) {
    on<LoadChapterContent>(_onLoadContent);
  }

  Future<void> _onLoadContent(
    LoadChapterContent event,
    Emitter<ChapterState> emit,
  ) async {
    emit(ChapterLoading());

    // Cargar todos los contenidos en paralelo
    final contentResults = await Future.wait(
      event.chapters.map((ch) => getChapterContent(ch.content)),
    );

    final resolved = <ChapterEntity>[];
    for (var i = 0; i < event.chapters.length; i++) {
      final ch = event.chapters[i];
      final result = contentResults[i];

      switch (result) {
        case Ok(:final value):
          resolved.add(ChapterEntity(
            id: ch.id,
            createdAt: ch.createdAt,
            number: ch.number,
            title: ch.title,
            content: value,
            tookId: ch.tookId,
          ));
        case Err(:final error):
          // Detener en el primer error
          emit(ChapterError('Error al cargar capítulos: ${error.message}'));
          NotificationService.error(
              'Error al cargar capítulos: ${error.message}');
          return;
      }
    }

    if (emit.isDone) return;
    emit(ChapterLoaded(resolved, initialIndex: event.initialIndex));
  }
}
```

**Beneficio:** Si hay 10 capítulos, el tiempo total es ~1 query en paralelo vs 10 secuenciales.

---

## P1: Major - Correcciones Importantes

### P1-1: Memory Leak en AuthBloc

**Archivo:** `lib/features/presentation/bloc/auth/auth_bloc.dart`

**Problema:** `_listenAuthChanges()` puede acumular subscriptions si se llama múltiples veces.

**Cambio en el constructor (líneas 22-34):**

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Register register;
  final Logout logout;
  final GetCurrentUser getCurrentUser;
  final ListenAuthState listenAuthState;
  StreamSubscription? _authSubscription;
  bool _manualLogoutInProgress = false;

  AuthBloc({
    required this.login,
    required this.register,
    required this.logout,
    required this.getCurrentUser,
    required this.listenAuthState,
  }) : super(AuthInitial()) {
    on<CheckAuthSession>(_onCheckSession);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);

    // SUSCRIPCIÓN EN CONSTRUCTOR - solo se ejecuta una vez
    _authSubscription = listenAuthState().listen((event) {
      if (event == domain.AuthEvent.signedOut && !_manualLogoutInProgress) {
        add(LogoutRequested());
      }
    });
  }
```

**Eliminamos** la función `_listenAuthChanges()` y su llamada.

---

### P1-2: Lógica incorrecta en `_getProfile` durante registro

**Archivo:** `lib/features/auth/data/auth_repository_impl.dart`

**Problema:** Si el `insert` falla silenciosamente, retorna OK incorrectamente.

**Cambio (líneas 127-139):**

```dart
// ANTES
if (response == null) {
  try {
    await _supabase.client.from('profiles').insert({
      'id': userId,
      'role': 'user',
    });
  } catch (e) {
    return Err(ProfileFailure(
      'No se pudo crear el perfil automáticamente',
      cause: e,
    ));
  }
  return Ok({'role': 'user'});
}

// DESPUÉS
if (response == null) {
  bool insertSucceeded = false;
  try {
    await _supabase.client.from('profiles').insert({
      'id': userId,
      'role': 'user',
    });
    insertSucceeded = true;
  } catch (e) {
    return Err(ProfileFailure(
      'No se pudo crear el perfil automáticamente',
      cause: e,
    ));
  }
  if (!insertSucceeded) {
    return Err(ProfileFailure('No se pudo crear el perfil automáticamente'));
  }
  return Ok({'role': 'user'});
}
```

**Mejora adicional:** Verificar que el perfil existe después del insert:

```dart
if (response == null) {
  try {
    await _supabase.client.from('profiles').insert({
      'id': userId,
      'role': 'user',
    });

    // Verificar que se creó correctamente
    final verify = await _supabase.client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    if (verify == null) {
      return Err(ProfileFailure('Perfil no encontrado después de crear'));
    }

    return Ok(Map<String, dynamic>.from(verify));
  } catch (e) {
    return Err(ProfileFailure(
      'No se pudo crear el perfil automáticamente',
      cause: e,
    ));
  }
}
```

---

### P1-3: Sin Pagination en getBooks

**Archivo:** `lib/features/books/data/book_repository_impl.dart`

**Problema:** `limit(100)` trunca datos si hay más libros.

**Cambio en el método `getBooks` (líneas 14-30):**

```dart
// NUEVA FIRMA
Future<Result<List<BookEntity>>> getBooks({
  bool onlyVisible = false,
  int page = 1,
  int pageSize = 50,
}) async {
  try {
    final offset = (page - 1) * pageSize;

    var query = _supabase.client.from('books').select(
        '*, authors(*), books_genres(genre_id, genres(*)), books_labels(*, labels(*)), tooks(*, chapters(*))');

    if (onlyVisible) {
      query = query.eq('is_visible', true);
    }

    final response = await query
        .order('id')
        .limit(pageSize)
        .range(offset, offset + pageSize - 1);

    final books = response.map((json) => BookModel.fromJson(json)).toList();
    return Ok(books);
  } catch (e) {
    return Err(BookFailure('Error al obtener libros', cause: e));
  }
}
```

**También actualizar** el repository interface en `lib/features/books/domain/book_repository.dart`.

---

### P1-4: Capítulo 11 - Falta validación de tamaño de archivo

**Archivo:** `lib/features/books/data/book_repository_impl.dart`

**Método `uploadCover` (líneas 180-190)**

**Cambio:**

```dart
static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

@override
Future<Result<String>> uploadCover(String filePath) async {
  try {
    final file = File(filePath);

    // Validar tamaño
    final fileSize = await file.length();
    if (fileSize > maxFileSizeBytes) {
      return Err(BookFailure(
        'El archivo es demasiado grande. Máximo: 5MB',
      ));
    }

    final ext = filePath.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!allowedExtensions.contains(ext)) {
      return Err(BookFailure(
        'Formato no permitido. Usa: JPG, PNG, o WebP',
      ));
    }

    final filename = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _supabase.client.storage.from('covers').upload(filename, file);
    return Ok(filename);
  } catch (e) {
    return Err(BookFailure('Error al subir cover', cause: e));
  }
}
```

---

## P2: Minor - Mejoras de UX

### P2-1: Capítulo 12 - Logger en Producción

**Archivo:** `lib/core/utils/logger.dart`

**Mejora:** Usar `kDebugMode` para separar logs de desarrollo y producción.

```dart
import 'package:flutter/foundation.dart';

class AppLogger {
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) debugPrint('   Cause: $error');
      if (stackTrace != null) debugPrint('   Stack: $stackTrace');
    }
    // En producción: enviar a crash reporting service
    // TODO: Integrar Sentry/Firebase Crashlytics
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️  WARNING: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️  INFO: $message');
    }
  }
}
```

**Recomendación:** Agregar integración con Sentry o Firebase Crashlytics para producción.

---

### P2-2: Capítulo 13 - UTF-8 Malformed en ChapterCache

**Archivo:** `lib/core/supabase/chapter_cache.dart`

**Cambio (línea 26):**

```dart
// ANTES
return utf8.decode(await file.readAsBytes());

// DESPUÉS
return utf8.decode(await file.readAsBytes(), allowMalformed: true);
```

---

### P2-3: Naming Inconsistency

**Archivo:** `lib/features/presentation/screens/book/book_screen.dart`

**Cambio (línea 10-12):**

```dart
// ANTES
class BookScreen extends StatefulWidget {
  final BookEntity books;
  const BookScreen({super.key, required this.books});
}

// DESPUÉS
class BookScreen extends StatefulWidget {
  final BookEntity book;
  const BookScreen({super.key, required this.book});
}

// Y actualizar todas las referencias a widget.books -> widget.book
```

---

## P3: Sugerencias de Código

### P3-1: Eliminar comentarios innecesarios

**Archivos:** Principalmente `lib/features/presentation/screens/main_screen.dart`

Eliminar comentarios como:
- Línea 53: `// Manejo de estados: muestra un indicador de carga...`
- Línea 58: `// Manejo de errores: muestra un mensaje de error...`
- etc.

Mantener solo comentarios que expliquen **por qué** se hace algo, no **qué** se hace.

---

### P3-2: Hardcoded bucket names

**Archivos:** `lib/features/books/data/book_repository_impl.dart`, `lib/features/chapters/data/chapter_repository_impl.dart`

**Crear constantes centralizadas:**

```dart
// lib/core/constants/storage_constants.dart
class StorageConstants {
  static const String coversBucket = 'covers';
  static const String chaptersBucket = 'chapters';
}
```

---

## Orden de Implementación Sugerido

| Orden | Issue | Archivos | Tiempo Est. |
|-------|-------|----------|-------------|
| 1 | P0-1 | `cover_url_service.dart` | 2 min |
| 2 | P0-2 | `app_drawer.dart` | 2 min |
| 3 | P0-3 | `chapter_bloc.dart` | 5 min |
| 4 | P1-1 | `auth_bloc.dart` | 3 min |
| 5 | P1-2 | `auth_repository_impl.dart` | 5 min |
| 6 | P1-3 | `book_repository_impl.dart` + interface | 10 min |
| 7 | P1-4 | `book_repository_impl.dart` (uploadCover) | 5 min |
| 8 | P2-1 | `logger.dart` | 3 min |
| 9 | P2-2 | `chapter_cache.dart` | 1 min |
| 10 | P2-3 | `book_screen.dart` | 2 min |
| 11 | P3-1 | `main_screen.dart` (comentarios) | 2 min |
| 12 | P3-2 | Crear constants + actualizar | 5 min |

**Total estimado:** ~45 minutos

---

## Verificación Post-Cambios

### Pruebas Manuales Requeridas

1. **Login/Registro:**
   - Crear cuenta nueva → verificar que el perfil se crea correctamente
   - Logout automático cuando el token expira

2. **Libros:**
   - Cargar lista de libros → verificar que se muestran todos
   - Subir cover > 5MB → debe mostrar error
   - Subir cover con formato inválido → debe mostrar error

3. **Capítulos:**
   - Abrir libro con muchos capítulos → verificar que no hay ANR
   - Contenido con caracteres especiales → debe mostrarse correctamente

4. **UI:**
   - Usuario sin avatar → debe mostrar icono default
   - Tema oscuro/claro → logger solo muestra en debug

---

## Notas de Migración

- **No hay cambios de schema** en la base de datos
- **No hay cambios de API** pública de los BLoCs
- **Compatible hacia atrás** con código existente que use los BLoCs

---

## Próximos Pasos

1. Confirmar que estás de acuerdo con este plan
2. Decidir si quieres que proceda con la implementación
3. ¿Prefieres que corrija todo de una vez o por partes (P0 primero)?

