# Tooks

> Unidades de volumen/archivo — los capítulos se agrupan en tooks dentro de un
> libro.

## Resumen

Los tooks representan volúmenes o ediciones compiladas de un libro. Cada libro
contiene uno o más tooks, y cada took contiene capítulos. Esta jerarquía de tres
niveles (Libro → Took → Capítulo) permite organizar el contenido en volúmenes
lógicos con sus propias portadas y metadatos.

## Modelo de datos

**`TookEntity`** (`lib/features/tooks/domain/took_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | Clave primaria |
| `createdAt` | `DateTime` | Marca de tiempo de creación |
| `cover` | `String` | Imagen de portada del volumen |
| `number` | `String` | Número de volumen (string de visualización) |
| `title` | `String` | Título del volumen |
| `chapterCount` | `int` | Cantidad de capítulos en este volumen |
| `bookId` | `int` | ID del libro padre |
| `listChapterIds` | `List<int>` | IDs de capítulos que pertenecen a este took |
| `createdBy` | `String?` | ID del usuario creador |

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetTooks | `FR<L<TookEntity>>` call() | Listar todos los tooks |
| GetTooksByBook | `FR<L<TookEntity>>` call(int bid) | Tooks de un libro |
| `GetTookById` | `Future<Result<TookEntity?>> call(int id)` | Took individual |
| CreateTook | `Future<Result<int>> call(TookEntity took)` | Crear nuevo took |
| UpdateTook | `FR<void>` call(TookEntity took) | Actualizar took |
| `DeleteTook` | `Future<Result<void>> call(int id)` | Eliminar un took |

**Repositorio**: `TookRepository` → `TookRepositoryImpl` consulta la tabla
`tooks`.

## Pantallas

### TookScreen

**Archivo**: `lib/features/tooks/presentation/screens/took_screen.dart`

- Muestra los metadatos del took y la lista de capítulos
- Navegación a capítulos individuales

### TookView

**Archivo**: `lib/features/tooks/presentation/views/took_view.dart`

- Tarjeta/vista compacta del took usada en las pantallas de detalle del libro

No tiene BLoC dedicado — los tooks se gestionan a través del `ScanTookBloc`
(feature scan) y se cargan como parte de `BookWithRelations` para las vistas de
lectura.

## Registro en DI

**Archivo**: `lib/features/tooks/di/injection_tooks.dart`

- `TookRepository` → `LazySingleton`
- Todos los casos de uso → `LazySingleton`

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de `TookEntity`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de Tooks
- [Books](../../es/features/books/README.md) — Entidad padre
- [Chapters](../../es/features/chapters/README.md) — Entidad hija
- [Tipos de usuario](../../es/user-types/scan-user.md) — Gestión de tooks
- [Base de datos](../../es/database/tables.md) — esquema de la tabla `tooks`

← Volver al [índice](../../es/README.md)
