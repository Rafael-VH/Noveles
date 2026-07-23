# Labels

> Etiquetas con código de color asignadas a libros — muchos a muchos mediante
> tabla intermedia.

## Resumen

El feature Labels gestiona etiquetas con código de color que se pueden asignar a
libros. Las etiquetas usan una tabla intermedia (`book_labels`) para relaciones
muchos a muchos. Solo los usuarios con rol scan pueden crear y gestionar
etiquetas; los usuarios regulares las ven como indicadores visuales en las
tarjetas de libros.

## Modelo de datos

**`LabelEntity`** (`lib/features/labels/domain/label_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | Clave primaria |
| `createdAt` | `DateTime` | Marca de tiempo de creación |
| `name` | `String` | Nombre de la etiqueta |
| `color` | `String` | Código de color hexadecimal |

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetLabels | `FR<L<LE>>` call() | Listar todas las etiquetas |
| CreateLabel | `FR<void>` call(LE label) | Crear una etiqueta |
| UpdateLabel | `FR<void>` call(int id,String n,String c) | Editar etiqueta |
| `DeleteLabel` | `FR<void>` call(int id) | Eliminar una etiqueta |
| AssignLabel | `FR<void>` call(int bid,int lid) | Asignar etiqueta a un libro |
| RemoveLabel | `FR<void>` call(int bid,int lid) | Quitar etiqueta de un libro |
| GetBookLabels | `FR<M<int,SE<int>>>` call(ids) | Búsqueda masiva etiquetas |

**Repositorio**: `LabelRepository` → `LabelRepositoryImpl` consulta las tablas
`labels` y `book_labels`.

## BLoC

**`LabelBloc`** (`lib/features/labels/presentation/bloc/label_bloc.dart`):

| Evento | Descripción |
| ------ | ----------- |
| `LoadLabels` | Cargar todas las etiquetas |
| `CreateLabelEvent` | Crear una nueva etiqueta |
| `UpdateLabelEvent` | Actualizar nombre/color de etiqueta |
| `DeleteLabelEvent` | Eliminar etiqueta |
| `AssignLabelToBook` | Asignar etiqueta a un libro |
| `RemoveLabelFromBook` | Quitar etiqueta de un libro |
| `LoadBookLabels` | Cargar asignaciones de etiquetas en lote |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `LabelInitial` | — | Inicial |
| `LabelLoading` | — | Obteniendo |
| `LabelLoaded` | `List<LabelEntity> labels` | Etiquetas cargadas |
| `BookLabelsLoaded` | `Map<int, Set<int>> bookLabels` | Asignaciones cargadas |
| `LabelError` | `String message` | Error |

## Pantallas

### LabelManagementScreen

**Archivo**:
`lib/features/labels/presentation/screens/label_management_screen.dart`

- UI completa de CRUD para gestionar etiquetas
- Selector de color para etiquetas
- Accesible desde el drawer del usuario scan y la ruta nombrada
  `/label-management`

## Registro en DI

**Archivo**: `lib/core/di/injection_labels.dart`

- `LabelRepository` → `LazySingleton`
- Todos los casos de uso → `LazySingleton`
- `LabelBloc` → `Factory`

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de `LabelEntity`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de Labels
- [Books](../../es/features/books/README.md) — Los libros tienen asociaciones de
  etiquetas
- [Tipos de usuario](../../es/user-types/scan-user.md) — Acceso a gestión de
  etiquetas
- [Base de datos](../../es/database/tables.md) — tablas `labels`, `book_labels`

← Volver al [índice](../../es/README.md)
