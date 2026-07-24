# Labels

> Color-coded labels with automatic rules — manual assignment and
> server-side auto-labeling.

## Overview

The Labels feature manages color-coded tags that can be assigned to books.
Labels use a junction table (`book_labels`) for many-to-many relationships.
Only scan-role users can create and manage labels; regular users see them as
visual indicators on book cards.

This feature also includes **Label Rules** — automatic label assignment based
on configurable rules (new releases, most read, most popular, most favorited).
Rules are evaluated server-side by a Supabase Edge Function (`sync-labels`).

## Data Model

**`LabelEntity`** (`lib/features/labels/domain/label_entity.dart`):

| Field | Type | Description |
| ------- | ------ | ------------- |
| `id` | `int` | Primary key |
| `createdAt` | `DateTime` | Creation timestamp |
| `name` | `String` | Label name |
| `color` | `String` | Hex color code |

## Use Cases

| Use Case | Signature | Purpose |
| ---------- | ----------- | --------- |
| GetLabels | `FR<L<LE>>` call() | List all labels |
| CreateLabel | `FR<void>` call(LE label) | Create a label |
| UpdateLabel | `FR<void>` call(int id,String n,String c) | Update label |
| `DeleteLabel` | `FR<void>` call(int id) | Delete a label |
| AssignLabel | `FR<void>` call(int bid,int lid) | Assign label to book |
| RemoveLabel | `FR<void>` call(int bid,int lid) | Remove label from book |
| GetBookLabels | `FR<M<int,SE<int>>>` call(ids) | Batch label lookup |

**Repository**: `LabelRepository` → `LabelRepositoryImpl` queries `labels` and
`book_labels` tables.

## BLoC

**`LabelBloc`** (`lib/features/labels/presentation/bloc/label_bloc.dart`):

| Event | Description |
| ------- | ------------- |
| `LoadLabels` | Load all labels |
| `CreateLabelEvent` | Create a new label |
| `UpdateLabelEvent` | Update label name/color |
| `DeleteLabelEvent` | Delete label |
| `AssignLabelToBook` | Assign label to a book |
| `RemoveLabelFromBook` | Remove label from a book |
| `LoadBookLabels` | Batch-load label assignments |

| State | Data | When |
| ------- | ------ | ------ |
| `LabelInitial` | — | Initial |
| `LabelLoading` | — | Fetching |
| `LabelLoaded` | `List<LabelEntity> labels` | Labels loaded |
| `BookLabelsLoaded` | `Map<int, Set<int>> bookLabels` | Assignments loaded |
| `LabelError` | `String message` | Error |

## Screens

### LabelManagementScreen

**File**:
`lib/features/labels/presentation/screens/label_management_screen.dart`

- Full CRUD UI for managing labels
- Color picker for label colors
- Accessible via scan user drawer and named route `/label-management`

## Label Rules

### Data Model

**`LabelRuleEntity`** (`lib/features/labels/domain/label_rule_entity.dart`):

| Field | Type | Description |
| ------- | ------ | ------------- |
| `id` | `int` | Primary key |
| `labelId` | `int` | FK → labels(id), ON DELETE CASCADE |
| `ruleType` | `LabelRuleType` | Enum: newRelease, mostRead, mostPopular, mostFavorited |
| `params` | `Map<String, dynamic>` | JSON params (e.g., days, limit) |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime` | Last update timestamp |

### Rule Types

| Type | Value | params | Query Logic |
| ------- | ------- | -------- | ------------- |
| Novedad | `new_release` | `{"days": 30}` | Books within $days of creation |
| Más leídos | `most_read` | `{"limit": 10, "days": 30}` | Top N by book_views |
| Más populares | `most_popular` | `{"limit": 10}` | Top N by took+chapters |
| Más favoritos | `most_favorited` | `{"limit": 10}` | Top N by user_favorites |

### Use Cases

| Use Case | Signature | Purpose |
| ---------- | ----------- | --------- |
| GetRules | `FR<List<LabelRuleEntity>>` call() | List rules (newest first) |
| CreateRule | `FR<void>` call(labelId, ruleType, params) | Create a rule |
| UpdateRule | `FR<void>` call(ruleId, params) | Update rule params |
| DeleteRule | `FR<void>` call(int ruleId) | Delete a rule |

### LabelRulesBloc

**File**: `lib/features/labels/presentation/bloc/label_rules_bloc.dart`

| Event | Description |
| ------- | ------------- |
| `LoadLabelRules` | Load all rules |
| `CreateLabelRule` | Create a new rule (reloads on success) |
| `DeleteLabelRule` | Delete a rule (reloads on success) |

| State | Data | When |
| ------- | ------ | ------ |
| `LabelRulesInitial` | — | Initial |
| `LabelRulesLoading` | — | Fetching |
| `LabelRulesLoaded` | `List<LabelRuleEntity> rules, String? message` | Loaded |
| `LabelRulesError` | `String message` | Error |

### LabelRulesAdminTab

**File**: `lib/features/labels/presentation/screens/label_rules_admin_tab.dart`

- Accessible as a tab in `AdminDashScreen`
- Lists all rules with label name, rule type, and params
- FAB to create a new rule: label selector + rule type + dynamic params form
- Swipe-to-delete with confirmation

### Edge Function

**File**: `supabase/functions/sync-labels/index.ts`

- Deployed as a Supabase Edge Function with `service_role` key
- Iterates all rules, evaluates each against the database, syncs `books_labels`
- Can be triggered manually from the admin tab via Supabase REST API

## DI Registration

**File**: `lib/features/labels/di/injection_labels.dart`

- `LabelRepository` → `LazySingleton`
- All use cases → `LazySingleton`
- `LabelBloc` → `Factory`
- `LabelRuleRepository` → `LazySingleton`
- All 4 label rule use cases → `LazySingleton`
- `LabelRulesBloc` → `Factory`

## Related

- [Entities](../../domain/entities.md) — `LabelEntity` field details
- [Use Cases](../../domain/use-cases.md) — Label use case signatures
- [Books](../../features/books/README.md) — Books have label associations
- [User Types](../../user-types/scan-user.md) — Label management access
- [Database](../../database/tables.md) — `labels`, `book_labels` tables

← Back to [index](../../README.md)
