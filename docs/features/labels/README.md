# Labels

> Color-coded labels with book assignment — many-to-many via junction table.

## Overview

The Labels feature manages color-coded tags that can be assigned to books.
Labels use a junction table (`book_labels`) for many-to-many relationships. Only
scan-role users can create and manage labels; regular users see them as visual
indicators on book cards.

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

## DI Registration

**File**: `lib/core/di/injection_labels.dart`

- `LabelRepository` → `LazySingleton`
- All use cases → `LazySingleton`
- `LabelBloc` → `Factory`

## Related

- [Entities](../../domain/entities.md) — `LabelEntity` field details
- [Use Cases](../../domain/use-cases.md) — Label use case signatures
- [Books](../../features/books/README.md) — Books have label associations
- [User Types](../../user-types/scan-user.md) — Label management access
- [Database](../../database/tables.md) — `labels`, `book_labels` tables

← Back to [index](../../README.md)
