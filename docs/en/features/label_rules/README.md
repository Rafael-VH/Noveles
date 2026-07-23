# Label Rules

> Automatic label assignment based on configurable rules — admin-managed, edge-function-executed.

## Overview

The Label Rules feature extends Labels with automatic assignment. Instead of
manually assigning labels to books, admins define rules that evaluate book data
(creation date, views, favorites) and automatically assign/remove labels via a
Supabase Edge Function (`sync-labels`).

**Key design**: Rules are evaluated server-side by
`supabase/functions/sync-labels/index.ts`. The Flutter app provides CRUD for
rules and a manual "sync now" trigger, but never evaluates rules itself.

## Data Model

**`LabelRuleEntity`** (`lib/features/label_rules/domain/label_rule_entity.dart`):

| Field | Type | Description |
| ------- | ------ | ------------- |
| `id` | `int` | Primary key |
| `labelId` | `int` | FK → labels(id), ON DELETE CASCADE |
| `ruleType` | `LabelRuleType` | Enum: newRelease, mostRead, mostPopular |
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

## Use Cases

| Use Case | Signature | Purpose |
| ---------- | ----------- | --------- |
| GetRules | `FR<List<LabelRuleEntity>>` call() | List rules (newest first) |
| CreateRule | `FR<void>` call(labelId, ruleType, params) | Create a rule |
| UpdateRule | `FR<void>` call(ruleId, params) | Update rule params |
| DeleteRule | `FR<void>` call(int ruleId) | Delete a rule |

**Repository**: `LabelRuleRepository` → `LabelRuleRepositoryImpl` queries the
`label_rules` table via Supabase client.

## BLoC

**`LabelRulesBloc`** (`lib/features/label_rules/presentation/bloc/label_rules_bloc.dart`):

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

## UI

### LabelRulesAdminTab

**File**: `lib/features/label_rules/presentation/screens/label_rules_admin_tab.dart`

- Accessible as the 6th tab in `AdminDashScreen` (after Analytics, Books, Genres,
  Users, Labels)
- Lists all rules with label name, rule type, and params
- FAB to create a new rule: label selector + rule type + dynamic params form
- Swipe-to-delete with confirmation
- Snackbar feedback on success/error

## Edge Function

**File**: `supabase/functions/sync-labels/index.ts`

- Deployed as a Supabase Edge Function with `service_role` key
- Iterates all rules, evaluates each against the database, syncs `books_labels`
- Can be triggered manually from the admin tab via Supabase REST API
- Originally designed for pg_cron scheduling, but pg_cron is unavailable in the
  current Supabase plan

## DI Registration

**File**: `lib/core/di/injection_labels.dart` (shared with the Labels feature)

- `LabelRuleRepository` → `LazySingleton`
- All 4 use cases → `LazySingleton`
- `LabelRulesBloc` → `Factory`

## Related

- [Labels](../../features/labels/README.md) — Manual label management, labels are
  the target of rules
- [Entities](../../domain/entities.md) — `LabelRuleEntity`, `LabelRuleType` enum
- [Use Cases](../../domain/use-cases.md) — Label rule use case signatures
- [User Types](../../user-types/admin-user.md) — Only admin can manage rules
- [Database](../../database/tables.md) — `label_rules` table schema
- [Database](../../database/rls-policies.md) — label_rules RLS policies

← Back to [index](../../README.md)
