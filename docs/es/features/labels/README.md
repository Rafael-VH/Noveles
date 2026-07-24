# Labels

> Etiquetas con código de color y reglas automáticas — asignación manual y
> etiquetado automático del lado del servidor.

## Resumen

El feature Labels gestiona etiquetas con código de color que se pueden asignar a
libros. Las etiquetas usan una tabla intermedia (`book_labels`) para relaciones
muchos a muchos. Solo los usuarios con rol scan pueden crear y gestionar
etiquetas; los usuarios regulares las ven como indicadores visuales en las
tarjetas de libros.

Esta funcionalidad también incluye **Label Rules** — asignación automática de
etiquetas basada en reglas configurables (nuevos lanzamientos, más leídos, más
populares, más favoritos). Las reglas se evalúan del lado del servidor mediante
una Supabase Edge Function (`sync-labels`).

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

## Label Rules

### Modelo de datos

**`LabelRuleEntity`** (`lib/features/labels/domain/label_rule_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | Clave primaria |
| `labelId` | `int` | FK → labels(id), ON DELETE CASCADE |
| `ruleType` | `LabelRuleType` | Enum: newRelease, mostRead, mostPopular, mostFavorited |
| `params` | `Map<String, dynamic>` | Parámetros JSON (ej., days, limit) |
| `createdAt` | `DateTime` | Marca de tiempo de creación |
| `updatedAt` | `DateTime` | Marca de tiempo de última actualización |

### Tipos de regla

| Tipo | Valor | params | Lógica de consulta |
| ---- | ----- | ------ | ------------------ |
| Novedad | `new_release` | `{"days": 30}` | Libros dentro de $days creación |
| Más leídos | `most_read` | `{"limit": 10,"days":30}` | Top N por book_views |
| Más populares | `most_popular` | `{"limit": 10}` | Top N por tooks+capítulos |
| Más favoritos | `most_favorited` | `{"limit":10}` | Top N por user_favorites |

### Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetRules | `FR<List<LabelRuleEntity>>` call() | Listar reglas (nuevas 1ro) |
| CreateRule | `FR<void>` call(labelId, ruleType, params) | Crear una regla |
| UpdateRule | `FR<void>` call(ruleId, params) | Editar params regla |
| DeleteRule | `FR<void>` call(int ruleId) | Eliminar una regla |

### LabelRulesBloc

**Archivo**: `lib/features/labels/presentation/bloc/label_rules_bloc.dart`

| Evento | Descripción |
| ------ | ----------- |
| `LoadLabelRules` | Cargar todas las reglas |
| `CreateLabelRule` | Crear una nueva regla (recarga al éxito) |
| `DeleteLabelRule` | Eliminar una regla (recarga al éxito) |

| Estado | Dato | Cuándo |
| ------ | ---- | ------ |
| `LabelRulesInitial` | — | Inicial |
| `LabelRulesLoading` | — | Obteniendo |
| `LabelRulesLoaded` | `List<LabelRuleEntity> rules, String? message` | Listo |
| `LabelRulesError` | `String message` | Error |

### LabelRulesAdminTab

**Archivo**: `lib/features/labels/presentation/screens/label_rules_admin_tab.dart`

- Accesible como pestaña en `AdminDashScreen`
- Lista todas las reglas con nombre de etiqueta, tipo de regla y parámetros
- FAB para crear una nueva regla: selector de etiqueta + tipo de regla +
  formulario de parámetros dinámicos
- Deslizar para eliminar con confirmación

### Edge Function

**Archivo**: `supabase/functions/sync-labels/index.ts`

- Desplegada como Supabase Edge Function con clave `service_role`
- Itera todas las reglas, evalúa cada una contra la base de datos y sincroniza
  `books_labels`
- Se puede disparar manualmente desde la pestaña de admin mediante la API REST
  de Supabase

## Registro en DI

**Archivo**: `lib/features/labels/di/injection_labels.dart`

- `LabelRepository` → `LazySingleton`
- Todos los casos de uso → `LazySingleton`
- `LabelBloc` → `Factory`
- `LabelRuleRepository` → `LazySingleton`
- Los 4 casos de uso de label rules → `LazySingleton`
- `LabelRulesBloc` → `Factory`

## Relacionados

- [Entidades](../../es/domain/entities.md) — detalles de campos de `LabelEntity`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de Labels
- [Books](../../es/features/books/README.md) — Los libros tienen asociaciones de
  etiquetas
- [Tipos de usuario](../../es/user-types/scan-user.md) — Acceso a gestión de
  etiquetas
- [Base de datos](../../es/database/tables.md) — tablas `labels`, `book_labels`

← Volver al [índice](../../es/README.md)
