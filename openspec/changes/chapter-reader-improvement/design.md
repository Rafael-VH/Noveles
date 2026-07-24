# Design: Chapter Reader Improvement

## Technical Approach

Refactor in 3 independent layers: (1) Bloc + data layer for lazy loading and `ContentType`, (2) ChapterScreen for controllers, reading settings, and progress, (3) TookScreen visual. Each layer is independently testable and revertable.

---

## Architecture Decisions

### Decision: Bloc-managed `Map<int, ChapterEntity>` cache

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Bloc holds a `Map<int, ChapterEntity>` + emits `ChapterLoadedSingle` per chapter | More states, but each page gets exactly what it needs | **Selected** — matches existing `Equatable` pattern, keeps cache in bloc (not UI) |
| UI manages cache in `_ChapterScreenState` | Breaks separation, bloc becomes passthrough | Rejected |
| `SetState` in screen instead of bloc events | Avoids event boilerplate but couples UI to data fetching | Rejected |

### Decision: `ContentType` enum on entity + DB column

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Enum on entity only, infer at runtime from existing data | No DB migration needed | **Selected** — column is additive, existing rows default to storage path |
| Enum + DB column with migration | Schema change for an internal detail | Deferred — column optional; can add later for queryability |

### Decision: Per-page ScrollControllers via listener on PageController

| Option | Tradeoff | Decision |
|--------|----------|----------|
| `PageView` `onPageChanged` listener creates/saves scroll controllers | Ties controller lifecycle to page transitions | **Selected** — `_ChapterScreenState` holds `Map<int, ScrollController>`, created lazily |
| Each page creates its own ScrollController in `itemBuilder` | Uncontrolled lifecycle, no save/restore hook | Rejected |

### Decision: Reading mode as local state, not bloc

| Option | Tradeoff | Decision |
|--------|----------|----------|
| `_ChapterScreenState` fields for fontSize and mode | Simple, scoped to reader, no event boilerplate | **Selected** — no server sync needed, modes are ephemeral |
| New bloc `ReaderSettingsBloc` | Over-engineered for 3 modes + 1 value | Rejected |

### Decision: Scroll position persistence via `shared_preferences`

| Option | Tradeoff | Decision |
|--------|----------|----------|
| `shared_preferences` keyed by `chapter_{id}` | Simple, survives restarts, 2s debounce | **Selected** — new dep, but well-known and sufficient |
| SQLite/Hive | Too heavy for a key-value offset | Rejected |

---

## Data Flow

```
                    ┌──────────────────────┐
                    │   ChapterScreen       │
                    │  (StatefulWidget)     │
                    │                       │
                    │  Map<int, ScrollCtrl> │── debounced save ──► SharedPreferences
                    │  fontSize, mode       │
                    └──┬────▲───────────────┘
                       │    │
          LoadChp      │    │ ChapterLoadedSingle
          PreloadAdj   │    │
                       ▼    │
                    ┌──────────────────────┐
                    │   ChapterBloc         │
                    │                       │
                    │  Map<int, ChapterEnt> │── in-memory cache
                    │  preloadBuffer        │
                    └──┬────▲───────────────┘
                       │    │
         downloadContent   │ Ok(content)
                       ▼    │
               ┌──────────────────┐
               │ ChapterRepository │── _isStoragePath → enum check
               │ Impl             │── ChapterCache (read-through)
               └──────────────────┘
```

---

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `lib/features/chapters/domain/chapter_entity.dart` | Modify | Add `contentType` field + `ChapterContentType` enum |
| `lib/features/chapters/domain/chapter_ref.dart` | Modify | Add `contentType` field |
| `lib/features/chapters/data/chapter_model.dart` | Modify | Serialize/deserialize `contentType` |
| `lib/features/chapters/data/chapter_repository_impl.dart` | Modify | Replace `_isStoragePath` with `ChapterContentType` check |
| `lib/features/chapters/presentation/bloc/chapter_event.dart` | Modify | Add `LoadChapter`, `PreloadAdjacent` events |
| `lib/features/chapters/presentation/bloc/chapter_state.dart` | Modify | Add `ChapterLoadedSingle`, `ChapterLoadError` states |
| `lib/features/chapters/presentation/bloc/chapter_bloc.dart` | Rewrite | Replace `Future.wait` with lazy `Map<int, ChapterEntity>` cache, preload adjacent logic |
| `lib/features/chapters/presentation/screens/chapter_screen.dart` | Rewrite | Instance PageController, per-page ScrollControllers, reading settings, scroll mark, typography, position indicator |
| `lib/features/chapters/presentation/screens/widgets/reading_settings_bar.dart` | Create | Font size +/- controls + mode toggle (normal/sepia/night) |
| `lib/features/tooks/presentation/screens/took_screen.dart` | Modify | Styled header with cover, loading indicator, read-status chapter list |
| `lib/features/chapters/presentation/screens/widgets/took_sliver_header.dart` | Create | Reusable styled header with cover (similar to `SliverAppBarBook`) |
| `lib/core/supabase/chapter_cache.dart` | Modify | Add `clear()` method for stale entries |
| `lib/core/di/injection_chapters.dart` | Modify | No structural change needed (bloc already factory-registered) |
| `pubspec.yaml` | Modify | Add `shared_preferences` dependency |
| `supabase/migrations/..._add_content_type.sql` | Create | Add `content_type` column to chapters table |

---

## Interfaces / Contracts

### ChapterContentType enum
```dart
enum ChapterContentType { inline, storagePath }
```

### ChapterEntity — new field
```dart
class ChapterEntity extends Equatable {
  // ... existing fields
  final ChapterContentType contentType;

  const ChapterEntity({
    // ... existing
    this.contentType = ChapterContentType.storagePath, // default for existing rows
  });
}
```

### Bloc events
```dart
class LoadChapter extends ChapterEvent {
  final int index;       // position in the full chapter list
  final List<ChapterRef> refs;  // all refs for context

  const LoadChapter({required this.index, required this.refs});
}

class PreloadAdjacent extends ChapterEvent {
  final int currentIndex;       // user's current position
  final List<ChapterRef> refs;  // all refs for context

  const PreloadAdjacent({required this.currentIndex, required this.refs});
}
```

### Bloc states
```dart
class ChapterLoadedSingle extends ChapterState {
  final Map<int, ChapterEntity> cache;   // chapter-id → entity
  final int currentIndex;
  final int totalCount;                  // for "X of Y"
  final List<int> chapterOrder;          // ordered chapter IDs

  ChapterLoadedSingle({required this.cache, required this.currentIndex,
                       required this.totalCount, required this.chapterOrder});
}

class ChapterLoadError extends ChapterState {
  final int chapterId;
  final String message;

  ChapterLoadError({required this.chapterId, required this.message});
}
```

### Reading mode enum
```dart
enum ReadingMode { normal, sepia, night }
```

---

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Bloc unit | `LoadChapter` loads single chapter, emits `ChapterLoadedSingle` | `blocTest` with `MockGetChapterContent` |
| Bloc unit | `PreloadAdjacent` loads next 3, skips loaded | `blocTest` — verify cache size |
| Bloc unit | Error on single chapter -> `ChapterLoadError`, does NOT clear existing | `blocTest` |
| Bloc unit | Chapter order preservation across loads | `blocTest` |
| Repository unit | `downloadContent` dispatches to storage vs inline based on `contentType` | `MockSupabaseClient` — verify paths |
| Model unit | `ChapterModel.fromJson` / `toJson` roundtrip with `contentType` | Direct Dart test |
| Widget (ChapterScreen) | PageController created once | `testWidgets` — check instance identity |
| Widget (ChapterScreen) | ScrollControllers change per page | Mock `PageController`, verify listeners |
| Widget (ChapterScreen) | Font size changes reflect in text | Pump widget, simulate button tap, verify `Text` style |
| Widget (ChapterScreen) | Sepia mode changes scaffold bg color | Pump, toggle, check `Scaffold.backgroundColor` |
| Widget (ChapterScreen) | Mark as read fires at 80%+ scroll | Mock `ScrollController.position`, verify `MarkChapterAsRead` call |
| Widget (ChapterScreen) | Mark as read fires ONCE per chapter | Same as above, verify called(1) |
| Widget (ChapterScreen) | "Chapter X of Y" updates on page change | Pump, simulate page change, verify label |
| Widget (ChapterScreen) | Scroll offset saved on page change | Pump, swipe, verify `SharedPreferences` called (debounced) |
| Widget (TookScreen) | Styled header with cover shows when present | `testWidgets` — find `CachedNetworkImage` |
| Widget (TookScreen) | Loading indicator shows during fetch | Pump before `_loadReadChapterIds` resolves |
| Widget (TookScreen) | Read chapters show grey, unread show theme default | Existing test extended with styled header |

Existing tests to update: `chapter_bloc_test.dart` (events/states changed), `chapter_screen_read_test.dart` (mark moved from initState to scroll), `took_screen_test.dart` (new header structure).

---

## Migration / Rollout

- **DB**: Additive migration (new column, nullable, default null → code defaults to `storagePath`).
- **Bloc**: Old events removed — no backward compat. Rollback = `git revert` on the 3-layer commits.
- **Chained PR recommendation**: YES — Layer 1 (bloc + data) should land first, then Layer 2 (screen), then Layer 3 (took). This isolates risk and makes review manageable.

## Open Questions

- [ ] Confirm `shared_preferences` key format: `chapter_scroll_{chapterId}` or `{userId}_chapter_{chapterId}`? (session-only makes user prefix unnecessary, but for cross-session it matters)
