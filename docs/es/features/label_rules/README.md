# Label Rules

> Asignación automática de etiquetas basada en reglas configurables — gestionado
> por admin, ejecutado por edge function.

## Resumen

El feature Label Rules extiende Labels con asignación automática. En lugar de
asignar etiquetas manualmente a los libros, los admins definen reglas que
evalúan datos del libro (fecha de creación, vistas, favoritos) y asignan/quitan
etiquetas automáticamente mediante una Supabase Edge Function (`sync-labels`).

**Decisión de diseño**: Las reglas se evalúan del lado del servidor mediante
`supabase/functions/sync-labels/index.ts`. La app Flutter provee CRUD para las
reglas y un disparador manual de "sincronizar ahora", pero nunca evalúa las
reglas por sí misma.

## Modelo de datos

**`LabelRuleEntity`** (`lib/features/label_rules/domain/label_rule_entity.dart`):

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `id` | `int` | Clave primaria |
| `labelId` | `int` | FK → labels(id), ON DELETE CASCADE |
| `ruleType` | `LabelRuleType` | Enum: newRelease, mostRead, mostPopular |
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

## Casos de uso

| Caso de uso | Firma | Propósito |
| ----------- | ----- | --------- |
| GetRules | `FR<List<LabelRuleEntity>>` call() | Listar reglas (nuevas 1ro) |
| CreateRule | `FR<void>` call(labelId, ruleType, params) | Crear una regla |
| UpdateRule | `FR<void>` call(ruleId, params) | Editar params regla |
| DeleteRule | `FR<void>` call(int ruleId) | Eliminar una regla |

**Repositorio**: `LabelRuleRepository` → `LabelRuleRepositoryImpl` consulta la
tabla `label_rules` mediante el cliente de Supabase.

## BLoC

**`LabelRulesBloc`**
(`lib/features/label_rules/presentation/bloc/label_rules_bloc.dart`):

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

## UI

### LabelRulesAdminTab

**Archivo**:
`lib/features/label_rules/presentation/screens/label_rules_admin_tab.dart`

- Accesible como la 6.ª pestaña en `AdminDashScreen` (después de Analíticas,
  Libros, Géneros, Usuarios, Etiquetas)
- Lista todas las reglas con nombre de etiqueta, tipo de regla y parámetros
- FAB para crear una nueva regla: selector de etiqueta + tipo de regla +
  formulario de parámetros dinámicos
- Deslizar para eliminar con confirmación
- Feedback con snackbar al éxito/error

## Edge Function

**Archivo**: `supabase/functions/sync-labels/index.ts`

- Desplegada como Supabase Edge Function con clave `service_role`
- Itera todas las reglas, evalúa cada una contra la base de datos y sincroniza
  `books_labels`
- Se puede disparar manualmente desde la pestaña de admin mediante la API REST
  de Supabase
- Originalmente diseñada para programación con pg_cron, pero pg_cron no está
  disponible en el plan actual de Supabase

## Registro en DI

**Archivo**: `lib/core/di/injection_labels.dart` (compartido con el feature
Labels)

- `LabelRuleRepository` → `LazySingleton`
- Los 4 casos de uso → `LazySingleton`
- `LabelRulesBloc` → `Factory`

## Relacionados

- [Labels](../../es/features/labels/README.md) — Gestión manual de etiquetas,
  las etiquetas son el destino de las reglas
- [Entidades](../../es/domain/entities.md) — `LabelRuleEntity`, enum
  `LabelRuleType`
- [Casos de uso](../../es/domain/use-cases.md) — firmas de casos de uso de Label
  Rules
- [Tipos de usuario](../../es/user-types/admin-user.md) — Solo admin puede
  gestionar reglas
- [Base de datos](../../es/database/tables.md) — esquema de la tabla
  `label_rules`
- [Base de datos](../../es/database/rls-policies.md) — Políticas RLS de
  label_rules

← Volver al [índice](../../es/README.md)
