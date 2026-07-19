# BLoC & State Management Fixes — Implementation Plan

> **17 issues** across 7 BLoC files, 9 event files, 9 state files.
> Estimated total: ~420 changed lines across ~16 files.
> Delivery strategy: single-pr with risk gates per phase.

---

## Table of Contents

- [Phase 0: Critical Fixes (C1, C2)](#phase-0-critical-fixes-c1-c2)
- [Phase 1: High Priority Fixes (H1–H4)](#phase-1-high-priority-fixes-h1h4)
- [Phase 2: Medium Priority Fixes (M1–M6)](#phase-2-medium-priority-fixes-m1m6)
- [Phase 3: Low Priority Fixes (L1–L5)](#phase-3-low-priority-fixes-l1l5)
- [Phase 4: Test Updates](#phase-4-test-updates)
- [Phase 5: Verification & Cleanup](#phase-5-verification--cleanup)

---

## Phase 0: Critical Fixes (C1, C2)

**Estimated time: 30 min**
**Risk: HIGH — These fix data-loss and race-condition bugs**

### C1 — GenreBloc emits Loading before reading state → genres lost after mutation

**File:** `lib/features/genres/presentation/bloc/genre_bloc.dart`

**Root cause:** `_onCreateGenre`, `_onUpdateGenre`, and `_onDeleteGenre` all emit `GenreLoading()` first. After that emit, `state is GenreLoaded` evaluates to `false`, so the `current` fallback in every mutation handler becomes `<GenreEntity>[]`. All loaded genres are silently discarded.

**Fix:** Capture `state` BEFORE emitting `GenreLoading`, OR (simpler) stop emitting `GenreLoading` during mutations entirely — keep current genres in memory.

**Chosen approach:** Save a reference to the loaded genres before the emit. This keeps the loading UX for initial loads while preserving data during mutations.

```dart
// Before (lines 46–61, _onCreateGenre):
Future<void> _onCreateGenre(
  CreateGenreEvent event,
  Emitter<GenreState> emit,
) async {
  emit(GenreLoading());
  final createResult = await createGenre(event.genre);
  switch (createResult) {
    case Ok():
      final current = state is GenreLoaded
          ? (state as GenreLoaded).genres
          : <GenreEntity>[];
      emit(GenreLoaded([...current, event.genre], message: 'Género creado'));
    case Err(:final error):
      emit(GenreError(error.message));
  }
}
```

```dart
// After:
Future<void> _onCreateGenre(
  CreateGenreEvent event,
  Emitter<GenreState> emit,
) async {
  final previousGenres = state is GenreLoaded
      ? (state as GenreLoaded).genres
      : <GenreEntity>[];
  emit(GenreLoading());
  final createResult = await createGenre(event.genre);
  switch (createResult) {
    case Ok():
      emit(GenreLoaded([...previousGenres, event.genre], message: 'Género creado'));
    case Err(:final error):
      emit(GenreError(error.message));
  }
}
```

Apply the **same pattern** to `_onUpdateGenre` (line 63–80) and `_onDeleteGenre` (line 82–98):

```dart
// _onUpdateGenre — capture before emit
Future<void> _onUpdateGenre(
  UpdateGenreEvent event,
  Emitter<GenreState> emit,
) async {
  final previousGenres = state is GenreLoaded
      ? (state as GenreLoaded).genres
      : <GenreEntity>[];
  emit(GenreLoading());
  final updateResult = await updateGenre(event.genre);
  switch (updateResult) {
    case Ok():
      final updated = previousGenres
          .map((g) => g.id == event.genre.id ? event.genre : g)
          .toList();
      emit(GenreLoaded(updated, message: 'Género actualizado'));
    case Err(:final error):
      emit(GenreError(error.message));
  }
}

// _onDeleteGenre — capture before emit
Future<void> _onDeleteGenre(
  DeleteGenreEvent event,
  Emitter<GenreState> emit,
) async {
  final previousGenres = state is GenreLoaded
      ? (state as GenreLoaded).genres
      : <GenreEntity>[];
  emit(GenreLoading());
  final deleteResult = await deleteGenre(event.id);
  switch (deleteResult) {
    case Ok():
      final filtered = previousGenres.where((g) => g.id != event.id).toList();
      emit(GenreLoaded(filtered, message: 'Género eliminado'));
    case Err(:final error):
      emit(GenreError(error.message));
  }
}
```

**Testing:** Run `flutter test test/bloc/genre_bloc_test.dart`. Add test: "Create/Update/Delete preserves previous genres on success".

---

### C2 — AuthBloc race condition — LogoutRequested not guarded by _manualLogoutInProgress

**File:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

**Root cause:** `_manualLogoutInProgress` is set inside the async `_onLogout` handler (line 103). Between the `add(LogoutRequested())` call and the handler executing, the stream listener can fire another `signedOut` → `add(LogoutRequested())` because the flag is still `false`.

**Fix:** Set `_manualLogoutInProgress = true` **synchronously** at the point where the logout is initiated by the stream listener.

```dart
// Before (lines 39–45):
void _listenAuthChanges() {
  _authSubscription = listenAuthState().listen((event) {
    if (event == domain.AuthEvent.signedOut && !_manualLogoutInProgress) {
      add(LogoutRequested());
    }
  });
}
```

```dart
// After:
void _listenAuthChanges() {
  _authSubscription = listenAuthState().listen((event) {
    if (event == domain.AuthEvent.signedOut && !_manualLogoutInProgress) {
      _manualLogoutInProgress = true; // Set synchronously before add()
      add(LogoutRequested());
    }
  });
}
```

Also keep the existing `_manualLogoutInProgress = false` at the **end** of `_onLogout` (line 112) and add early-return guard:

```dart
// _onLogout — add guard at top:
Future<void> _onLogout(
  LogoutRequested event,
  Emitter<AuthState> emit,
) async {
  _manualLogoutInProgress = true; // idempotent for manual triggers
  emit(AuthLoading());
  final result = await logout();
  switch (result) {
    case Ok():
      emit(AuthUnauthenticated());
    case Err(:final error):
      emit(AuthError(error.message));
  }
  _manualLogoutInProgress = false;
}
```

**Testing:** Run `flutter test test/bloc/auth_bloc_test.dart`. Add test: "Stream logout during manual logout does not trigger duplicate LogoutRequested".

---

## Phase 1: High Priority Fixes (H1–H4)

**Estimated time: 45 min**
**Risk: MEDIUM — Data fetching and architecture changes**

### H1 — LabelBloc _emitLoaded fetches ALL book-labels with empty filter

**File:** `lib/features/labels/presentation/bloc/label_bloc.dart`

**Root cause:** Line 44: `await getLabelsForBooks([])` passes an empty list, which may return ALL book-label associations or zero, depending on backend behavior.

**Fix:** After a mutation (assign/remove), pass the relevant book ID to only refresh that book's labels. Change `_emitLoaded` to accept an optional `bookId`:

```dart
// Before (line 39–54):
Future<void> _emitLoaded(Emitter<LabelState> emit, {String? message}) async {
  final labelsResult = await getLabels();
  switch (labelsResult) {
    case Ok(:final value):
      final loadedLabels = value;
      final bookLabelsResult = await getLabelsForBooks([]);
      // ...
```

```dart
// After:
Future<void> _emitLoaded(
  Emitter<LabelState> emit, {
  String? message,
  int? refreshBookId,
}) async {
  final labelsResult = await getLabels();
  switch (labelsResult) {
    case Ok(:final value):
      final loadedLabels = value;
      // If we know which book changed, only refresh that one.
      // Otherwise fall back to existing bookLabels from current state.
      final bookIds = refreshBookId != null
          ? [refreshBookId]
          : (state is LabelLoaded
              ? (state as LabelLoaded).bookLabels.keys.toList()
              : <int>[]);
      final bookLabelsResult = await getLabelsForBooks(bookIds);
      switch (bookLabelsResult) {
        case Ok(:final value):
          emit(LabelLoaded(loadedLabels, value, message: message));
        case Err(:final error):
          emit(LabelError(error.message));
      }
    case Err(:final error):
      emit(LabelError(error.message));
  }
}
```

Update callers:
```dart
// _onAssignLabel (line 120):
case Ok():
  await _emitLoaded(emit, message: 'Etiqueta asignada', refreshBookId: event.bookId);

// _onRemoveLabel (line 131):
case Ok():
  await _emitLoaded(emit, message: 'Etiqueta removida', refreshBookId: event.bookId);
```

**Testing:** Verify label management screen loads correctly; assign/remove a label and check only affected book labels refresh.

---

### H2 — LabelBloc loses all data on error during mutation

**File:** `lib/features/labels/presentation/bloc/label_bloc.dart`

**Root cause:** Lines 96, 116, 127, 138 all emit `LabelError(error.message)` on failure, replacing the loaded state entirely. The UI shows an error screen instead of keeping the current data visible.

**Fix:** On mutation errors, emit error state but **retain** loaded data by using a `LabelErrorWithLabels` or by adding the labels to `LabelError`. The simplest approach: preserve `LabelLoaded` and show the error via the `message` field:

```dart
// For _onCreateLabel error (line 95–97):
case Err(:final error):
  if (state is LabelLoaded) {
    final current = state as LabelLoaded;
    emit(LabelLoaded(current.labels, current.bookLabels,
        message: 'Error: ${error.message}'));
  } else {
    emit(LabelError(error.message));
  }
```

Apply the **same pattern** to `_onDeleteLabel`, `_onAssignLabel`, and `_onRemoveLabel` — on error, if `state is LabelLoaded`, keep the loaded data and put the error in the message field. If state is NOT loaded, fall back to `LabelError`.

**Testing:** Verify that creating/deleting a label that fails does NOT wipe the existing label list from the UI.

---

### H3 — ScanBloc is a God Class — 7 use cases, 6 event types

**File:** `lib/features/scan/presentation/bloc/scan_bloc.dart`

**Root cause:** `ScanBloc` handles book CRUD, cover upload, genre loading, and visibility toggling — all in one class with 7 use cases.

**Fix (structural — do NOT refactor now, just document):** This is a design debt item. The current `ScanBloc` is 177 lines and the handlers are well-separated. Mark this as technical debt. A future refactor would split into:

| Responsibility | New BLoC | Events |
|---|---|---|
| Book CRUD + visibility | `ScanBookBloc` | LoadBooks, SaveBook, DeleteBook, ToggleVisibility |
| Cover upload | `ScanCoverBloc` | UploadCover |
| Genre loading | `ScanGenreBloc` | LoadGenres |

**Action for this phase:** Add a `// TODO(tech-debt): Split ScanBloc into ScanBookBloc, ScanCoverBloc, ScanGenreBloc` comment at the top of `scan_bloc.dart`. Do NOT split now — it would require provider changes across the entire scan presentation layer.

**Testing:** No code change, no test needed.

---

### H4 — ChapterBloc sends entire chapter entities through events

**File:** `lib/features/chapters/presentation/bloc/chapter_event.dart`

**Root cause:** `LoadChapterContent` takes `List<ChapterEntity> chapters` (with 7 fields including full content strings). The BLoC only needs `id`, `content` (the URL/token), and `number` for loading. Sending full entities through the event bus is wasteful and makes events hard to compare.

**Fix:** Create a lightweight `ChapterRef` value object for events:

```dart
// Add to chapter_event.dart (or a new file lib/features/chapters/domain/chapter_ref.dart):
class ChapterRef extends Equatable {
  final int id;
  final String content;
  final String number;
  final String title;
  final int tookId;

  const ChapterRef({
    required this.id,
    required this.content,
    required this.number,
    required this.title,
    required this.tookId,
  });

  /// Create a ChapterRef from a ChapterEntity
  factory ChapterRef.fromEntity(ChapterEntity entity) => ChapterRef(
        id: entity.id,
        content: entity.content,
        number: entity.number,
        title: entity.title,
        tookId: entity.tookId,
      );

  @override
  List<Object> get props => [id, content, number, title, tookId];
}
```

Update `LoadChapterContent`:
```dart
// Before:
class LoadChapterContent extends ChapterEvent {
  final int initialIndex;
  final List<ChapterEntity> chapters;
  const LoadChapterContent({required this.initialIndex, required this.chapters});
  @override
  List<Object> get props => [initialIndex, chapters];
}

// After:
class LoadChapterContent extends ChapterEvent {
  final int initialIndex;
  final List<ChapterRef> chapters;
  const LoadChapterContent({required this.initialIndex, required this.chapters});
  @override
  List<Object> get props => [initialIndex, chapters];
}
```

Update `chapter_bloc.dart` handler:
```dart
// Before (line 26):
final contentResults = await Future.wait(
  event.chapters.map((ch) => getChapterContent(ch.content)),
);

final resolved = <ChapterEntity>[];
for (var i = 0; i < event.chapters.length; i++) {
  final ch = event.chapters[i];
  final result = contentResults[i];
  // ...
```

```dart
// After:
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
        createdAt: DateTime(0), // Not needed for display
        number: ch.number,
        title: ch.title,
        content: value,
        tookId: ch.tookId,
      ));
    case Err(:final error):
      emit(ChapterError('Error al cargar capítulos: ${error.message}'));
      return;
  }
}
```

**Update UI caller** in `chapter_screen.dart` (lines 54–59, 92–96):
```dart
// Before:
context.read<ChapterBloc>().add(
  LoadChapterContent(
    initialIndex: widget.i,
    chapters: widget.chapters,
  ),
);

// After:
context.read<ChapterBloc>().add(
  LoadChapterContent(
    initialIndex: widget.i,
    chapters: widget.chapters.map(ChapterRef.fromEntity).toList(),
  ),
);
```

**Risk:** Must find ALL places `LoadChapterContent` is dispatched. Grep confirmed only 2 call sites (both in `chapter_screen.dart`).

**Testing:** Run `flutter test test/bloc/chapter_bloc_test.dart`. Update test dispatches to use `ChapterRef`.

---

## Phase 2: Medium Priority Fixes (M1–M6)

**Estimated time: 40 min**
**Risk: LOW — Mostly cosmetic, const, and UX polish**

### M1 — GenreBloc and LabelBloc emit Loading during mutations — UI flashes spinner

**Files:** `genre_bloc.dart`, `label_bloc.dart`

**Root cause:** Mutation handlers (create/update/delete) emit `GenreLoading()` / `LabelLoading()` which triggers `CircularProgressIndicator` in the UI.

**Fix:** During mutations, do NOT emit loading. The existing data stays visible. Only emit the result state.

```dart
// genre_bloc.dart — _onCreateGenre, _onUpdateGenre, _onDeleteGenre:
// REMOVE emit(GenreLoading()); from all three mutation handlers.
// Keep it only in _onLoadGenres (initial load).

// label_bloc.dart — same pattern.
// REMOVE any emit(LabelLoading()); from mutation handlers.
// Keep it only in _onLoadLabels.
```

**UI impact:**
- `lib/features/app/presentation/screens/main_screen.dart` line 43: `if (bookState is BookLoading || genreState is GenreLoading)` — This only checks for initial load, which still emits Loading. No change needed.
- `lib/features/admin/presentation/screens/genres_tab.dart` line 53: Same — only checks initial load. No change needed.

**Testing:** Verify mutations no longer show spinner; data stays visible during create/update/delete.

---

### M2 — ScanCoverUploaded state loses book context

**File:** `lib/features/scan/presentation/bloc/scan_state.dart`

**Root cause:** `ScanCoverUploaded` only carries `filename`. The UI at `scan_book_edit_screen.dart` line 216 reads `_coverCtrl.text = state.filename` — this works because the controller is a local variable, not from state. The state itself loses context about which book the cover belongs to.

**Fix:** Not a bug in practice (the UI uses a local controller), but it's poor design. Add book context:

```dart
// Before:
class ScanCoverUploaded extends ScanState {
  final String filename;
  ScanCoverUploaded(this.filename);
  @override
  List<Object> get props => [filename];
}

// After:
class ScanCoverUploaded extends ScanState {
  final String filename;
  final int? bookId;
  const ScanCoverUploaded(this.filename, {this.bookId});
  @override
  List<Object> get props => [filename, bookId ?? ''];
}
```

Update the emit in `scan_bloc.dart` (line 52):
```dart
// Before:
emit(ScanCoverUploaded(value));

// After:
emit(ScanCoverUploaded(value, bookId: event.bookId));
```

Add `bookId` to `UploadScanCover` event:
```dart
class UploadScanCover extends ScanEvent {
  final String filePath;
  final int? bookId;
  const UploadScanCover(this.filePath, {this.bookId});
  @override
  List<Object> get props => [filePath, bookId ?? ''];
}
```

**Risk:** The `bookId` parameter is optional so this is backward-compatible. No existing code breaks.

**Testing:** Upload a cover and verify the filename still appears correctly in the form.

---

### M3 — GenreBloc and ScanChapterEvent missing const constructors

**Files:** `genre_state.dart`, `scan_chapter_event.dart`, `scan_chapter_state.dart`, `scan_took_event.dart`, `scan_took_state.dart`

```dart
// genre_state.dart — Add const constructors:
class GenreInitial extends GenreState {
  const GenreInitial();  // ADD
}
class GenreLoading extends GenreState {
  const GenreLoading();  // ADD
}
class GenreLoaded extends GenreState {
  final List<GenreEntity> genres;
  final String? message;
  const GenreLoaded(this.genres, {this.message});  // ADD const
  // ...
}
class GenreError extends GenreState {
  final String message;
  const GenreError(this.message);  // ADD const
  // ...
}

// scan_chapter_event.dart — Add const constructors:
abstract class ScanChapterEvent extends Equatable {
  const ScanChapterEvent();  // ADD const
  // ...
}
class SaveScanChapter extends ScanChapterEvent {
  final ChapterEntity chapter;
  final bool isUpdate;
  const SaveScanChapter(this.chapter, {required this.isUpdate});  // ADD const
  // ...
}
class DeleteScanChapter extends ScanChapterEvent {
  final int chapterId;
  const DeleteScanChapter(this.chapterId);  // ADD const
  // ...
}
class UploadChapterFile extends ScanChapterEvent {
  final String filePath;
  const UploadChapterFile(this.filePath);  // ADD const
  // ...
}

// scan_chapter_state.dart — Add const constructors:
abstract class ScanChapterState extends Equatable {
  const ScanChapterState();  // ADD const
  // ...
}
class ScanChapterInitial extends ScanChapterState {
  const ScanChapterInitial();  // ADD const
}
class ScanChapterLoading extends ScanChapterState {
  const ScanChapterLoading();  // ADD const
}
class ScanChapterLoaded extends ScanChapterState {
  final String? message;
  const ScanChapterLoaded({this.message});  // ADD const
  // ...
}
class ScanChapterError extends ScanChapterState {
  final String message;
  const ScanChapterError(this.message);  // ADD const
  // ...
}
class ScanChapterContentUploaded extends ScanChapterState {
  final String url;
  final String fileName;
  const ScanChapterContentUploaded(this.url, {this.fileName = ''});  // ADD const
  // ...
}

// scan_took_event.dart — Add const constructors:
abstract class ScanTookEvent extends Equatable {
  const ScanTookEvent();  // ADD const
  // ...
}
class SaveScanTook extends ScanTookEvent {
  final TookEntity took;
  final bool isUpdate;
  const SaveScanTook(this.took, {required this.isUpdate});  // ADD const
  // ...
}
class DeleteScanTook extends ScanTookEvent {
  final int tookId;
  const DeleteScanTook(this.tookId);  // ADD const
  // ...
}
class UploadTookCover extends ScanTookEvent {
  final String filePath;
  const UploadTookCover(this.filePath);  // ADD const
  // ...
}

// scan_took_state.dart — Add const constructors:
abstract class ScanTookState extends Equatable {
  const ScanTookState();  // ADD const
  // ...
}
class ScanTookInitial extends ScanTookState {
  const ScanTookInitial();  // ADD const
}
class ScanTookLoading extends ScanTookState {
  const ScanTookLoading();  // ADD const
}
class ScanTookLoaded extends ScanTookState {
  final String? message;
  const ScanTookLoaded({this.message});  // ADD const
  // ...
}
class ScanTookError extends ScanTookState {
  final String message;
  const ScanTookError(this.message);  // ADD const
  // ...
}
class ScanTookCoverUploaded extends ScanTookState {
  final String url;
  const ScanTookCoverUploaded(this.url);  // ADD const
  // ...
}
```

**Testing:** `flutter analyze` should pass. No behavior change.

---

### M4 — Inconsistent const usage across states and events

**Files:** Multiple

Review all state/event files and ensure EVERY concrete class that can have `const` does:

| File | Missing `const` | Add |
|---|---|---|
| `scan_state.dart` | `ScanInitial`, `ScanLoading`, `ScanLoaded`, `ScanCoverUploaded`, `ScanGenresLoaded`, `ScanError` | All |
| `chapter_state.dart` | `ChapterInitial`, `ChapterLoading`, `ChapterLoaded`, `ChapterError` | All |
| `profile_state.dart` | `ProfileInitial`, `ProfileLoading`, `ProfileLoaded`, `ProfileSaving`, `ProfileError` | All |
| `auth_state.dart` | `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError` | All |
| `auth_event.dart` | Already has const | ✅ |
| `theme_event.dart` | Already has const | ✅ |

Apply the same pattern as M3: add `const` to every constructor that doesn't hold mutable data or has all-final fields.

**Note:** `ScanLoaded`, `ScanGenresLoaded`, `ProfileLoaded`, etc. contain `List` or `Map` fields — these can still be `const` if the caller passes a const list. BUT in practice, lists come from API calls (not const), so adding `const` to these constructors is still valid — it just means the constructor *allows* const construction when possible.

```dart
// scan_state.dart:
class ScanInitial extends ScanState {
  const ScanInitial();
}
class ScanLoading extends ScanState {
  const ScanLoading();
}
class ScanLoaded extends ScanState {
  final List<BookWithRelations> books;
  final String? message;
  const ScanLoaded(this.books, {this.message});
  // ...
}
class ScanGenresLoaded extends ScanState {
  final List<BookWithRelations> books;
  final List<GenreEntity> genres;
  const ScanGenresLoaded(this.books, this.genres);
  // ...
}
class ScanError extends ScanState {
  final String message;
  const ScanError(this.message);
  // ...
}

// chapter_state.dart:
class ChapterInitial extends ChapterState {
  const ChapterInitial();
}
class ChapterLoading extends ChapterState {
  const ChapterLoading();
}
class ChapterLoaded extends ChapterState {
  final List<ChapterEntity> chapters;
  final int initialIndex;
  const ChapterLoaded(this.chapters, {this.initialIndex = 0});
  // ...
}
class ChapterError extends ChapterState {
  final String message;
  const ChapterError(this.message);
  // ...
}

// profile_state.dart:
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final String? pendingAvatarPath;
  final String? message;
  const ProfileLoaded(this.user, {this.pendingAvatarPath, this.message});
  // ...
}
class ProfileSaving extends ProfileState {
  final UserEntity user;
  const ProfileSaving(this.user);
  // ...
}
class ProfileError extends ProfileState {
  final String message;
  final UserEntity? user;
  const ProfileError(this.message, {this.user});
  // ...
}

// auth_state.dart:
class AuthInitial extends AuthState {
  const AuthInitial();
}
class AuthLoading extends AuthState {
  const AuthLoading();
}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  // ...
}
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  // ...
}
```

**Testing:** `flutter analyze` should pass. Tests that use `isA<GenreLoading>()` still work (const is a constructor detail, not a type check).

---

### M5 — GenreEvent naming — redundant "Event" suffix

**File:** `lib/features/genres/presentation/bloc/genre_event.dart`

**Root cause:** `CreateGenreEvent`, `UpdateGenreEvent`, `DeleteGenreEvent` have `Event` suffix while the base is `GenreEvent`. Convention is to NOT repeat the domain suffix on event subclasses (e.g., `CreateGenre`, not `CreateGenreEvent`).

**Fix:** Rename and update all references:

```dart
// genre_event.dart — rename:
class CreateGenreEvent → CreateGenre
class UpdateGenreEvent → UpdateGenre
class DeleteGenreEvent → DeleteGenre
```

**Files that reference these:**
- `genre_bloc.dart` — `on<CreateGenreEvent>` → `on<CreateGenre>`, handler signature
- `test/bloc/genre_bloc_test.dart` — all test dispatches

```dart
// genre_bloc.dart — before:
on<CreateGenreEvent>(_onCreateGenre);
on<UpdateGenreEvent>(_onUpdateGenre);
on<DeleteGenreEvent>(_onDeleteGenre);

// after:
on<CreateGenre>(_onCreateGenre);
on<UpdateGenre>(_onUpdateGenre);
on<DeleteGenre>(_onDeleteGenre);
```

**Risk:** This is a rename across 2-3 files. Must be thorough — missed references cause compile errors (safe to catch).

**Testing:** `flutter analyze` + `flutter test test/bloc/genre_bloc_test.dart`.

---

### M6 — ProfileBloc verbose state checking instead of pattern matching

**File:** `lib/features/profiles/presentation/bloc/profile_bloc.dart`

**Root cause:** Lines 50–51, 85–86, 94–95 use `if (currentState is! ProfileLoaded)` checks. The project already uses Dart 3 pattern matching (`switch`/`case`) elsewhere.

**Fix:** Replace verbose `is` checks with pattern matching where appropriate:

```dart
// Before (_onUpdateProfile, line 46–79):
Future<void> _onUpdateProfile(
  events.UpdateProfile event,
  Emitter<ProfileState> emit,
) async {
  final currentState = state;
  if (currentState is! ProfileLoaded) {
    emit(ProfileError('No se puede actualizar: perfil no cargado'));
    return;
  }
  emit(ProfileSaving(currentState.user));
  // ...
```

```dart
// After:
Future<void> _onUpdateProfile(
  events.UpdateProfile event,
  Emitter<ProfileState> emit,
) async {
  final currentState = state;
  switch (currentState) {
    case ProfileLoaded(:final user, :final pendingAvatarPath):
      emit(ProfileSaving(user));
      String? avatarUrl = user.avatarUrl;
      if (pendingAvatarPath != null) {
        final avatarResult = await uploadAvatar(pendingAvatarPath);
        switch (avatarResult) {
          case Ok(:final value):
            avatarUrl = value;
          case Err(:final error):
            emit(ProfileError(error.message, user: user));
            return;
        }
      }
      final updateResult = await updateProfile(
        displayName: event.displayName,
        bio: event.bio,
        avatarUrl: avatarUrl,
      );
      switch (updateResult) {
        case Ok(:final value):
          emit(ProfileLoaded(value, message: 'Perfil actualizado exitosamente'));
        case Err(:final error):
          emit(ProfileError(error.message, user: user));
      }
    default:
      emit(ProfileError('No se puede actualizar: perfil no cargado'));
  }
}
```

Apply same pattern to `_onPickAvatar` and `_onChangePassword`.

**Testing:** Run `flutter test test/bloc/profile_bloc_test.dart`.

---

## Phase 3: Low Priority Fixes (L1–L5)

**Estimated time: 20 min**
**Risk: VERY LOW — Cosmetic and configuration**

### L1 — ThemeBloc hardcodes dark mode as default

**File:** `lib/core/presentation/bloc/theme_bloc.dart`

**Root cause:** Line 11–12: `super(ThemeState(isDarkMode: true, themeData: DarkTheme.darkTheme))` always starts with dark mode.

**Fix:** Use `WidgetsBinding.instance.platformDispatcher.platformBrightness` to detect system theme:

```dart
// Before:
ThemeBloc() : super(ThemeState(isDarkMode: true, themeData: DarkTheme.darkTheme)) {

// After:
ThemeBloc() : super(_initialState()) {
```

```dart
// Add as a static method or top-level function:
static ThemeState _initialState() {
  final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  final isDark = brightness == Brightness.dark;
  return ThemeState(
    isDarkMode: isDark,
    themeData: isDark ? DarkTheme.darkTheme : LightTheme.lightTheme,
  );
}
```

**Note:** This requires importing `package:flutter/widgets.dart`. Also, `WidgetsBinding` may not be available before `runApp()`. A safer approach:

```dart
// In theme_bloc.dart:
import 'package:flutter/material.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({Brightness? initialBrightness})
      : super(_buildState(initialBrightness ?? Brightness.dark)) {
    on<ThemeChanged>((event, emit) {
      emit(ThemeState(
        isDarkMode: event.isDarkMode,
        themeData: event.isDarkMode ? DarkTheme.darkTheme : LightTheme.lightTheme,
      ));
    });
  }

  static ThemeState _buildState(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeState(
      isDarkMode: isDark,
      themeData: isDark ? DarkTheme.darkTheme : LightTheme.lightTheme,
    );
  }
}
```

**Update provider** in `lib/core/app/app.dart`:
```dart
// Before:
BlocProvider(create: (_) => ThemeBloc()),

// After:
BlocProvider(create: (_) => ThemeBloc(
  initialBrightness: MediaQueryData.fromView(
    WidgetsBinding.instance.platformDispatcher.views.first,
  ).platformBrightness,
)),
```

**Testing:** Toggle system dark/light mode and verify app starts with correct theme.

---

### L2 — ThemeBloc does not include themeData in Equatable props

**File:** `lib/core/presentation/bloc/theme_state.dart`

**Root cause:** Line 11: `List<Object> get props => [isDarkMode];` — `themeData` is excluded. If `isDarkMode` is the same but `themeData` changes (unlikely but possible), BlocBuilder won't rebuild.

**Fix:**
```dart
// Before:
@override
List<Object> get props => [isDarkMode];

// After:
@override
List<Object> get props => [isDarkMode, themeData];
```

**Risk:** `ThemeData` implements `==` by identity, not value. Including it in props means BlocBuilder will always rebuild if a new `ThemeState` is emitted (even if `isDarkMode` is the same). This is actually the correct behavior — if we emit a new state, we want rebuilds.

**Testing:** Toggle theme and verify the UI updates.

---

### L3 — AuthBloc imports event and state files twice

**File:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

**Root cause:** Lines 4–5 (exports) and lines 13–14 (imports) both reference `auth_event.dart` and `auth_state.dart`.

**Fix:** Remove the redundant imports (lines 13–14). The exports on lines 4–5 already make the types available within this file:

```dart
// Remove lines 13–14:
// import 'package:noveles/features/auth/presentation/bloc/auth_event.dart';   ← DELETE
// import 'package:noveles/features/auth/presentation/bloc/auth_state.dart';   ← DELETE
```

**Same issue in other BLoCs:** Check `genre_bloc.dart` (lines 3–4 exports + 11–12 imports), `label_bloc.dart` (lines 3–4 + 13–14), `scan_bloc.dart` (lines 3–4 + 14–15), `chapter_bloc.dart` (lines 3–4 + 8–9).

Remove redundant imports in ALL files:
- `genre_bloc.dart`: remove lines 11–12
- `label_bloc.dart`: remove lines 13–14
- `scan_bloc.dart`: remove lines 14–15
- `chapter_bloc.dart`: remove lines 8–9

**Testing:** `flutter analyze` should pass.

---

### L4 — No EventTransformer configuration on any BLoC

**Files:** All `*_bloc.dart` files

**Current state:** No BLoC uses `transformer:` parameter in `on<>()` calls. For sequential operations (like mutations), the default `debounce` or `droppable` transformers may be desirable.

**Action:** Add `transformer: sequential()` to mutation handlers to prevent concurrent mutations:

```dart
// In genre_bloc.dart:
on<CreateGenre>(_onCreateGenre, transformer: concurrent());  // or sequential()
on<UpdateGenre>(_onUpdateGenre, transformer: concurrent());
on<DeleteGenre>(_onDeleteGenre, transformer: concurrent());

// In label_bloc.dart:
on<CreateLabelEvent>(_onCreateLabel, transformer: concurrent());
on<DeleteLabelEvent>(_onDeleteLabel, transformer: concurrent());
on<AssignLabelEvent>(_onAssignLabel, transformer: concurrent());
on<RemoveLabelEvent>(_onRemoveLabel, transformer: concurrent());
```

**Recommendation:** Use `concurrent()` (the default) unless there's a specific reason to serialize. The default behavior is already concurrent — this task is to EXPLICITLY declare the intent. For now, add `transformer: concurrent()` only to mutation handlers as documentation of intent.

**Actually — this is low priority and adds no functional value.** Mark as documentation-only TODO:

```dart
// TODO(L4): Add explicit EventTransformer to mutation handlers for clarity
```

**Testing:** N/A for documentation.

---

### L5 — ScanChapterEvent and ScanTookEvent abstract classes missing const constructor

**Files:** `scan_chapter_event.dart`, `scan_took_event.dart`

Already covered in **M3**. These are the same fixes — adding `const` to the abstract base class constructors. The M3 section handles both.

**Status:** ✅ Covered by M3.

---

## Phase 4: Test Updates

**Estimated time: 30 min**

### Test files to update:

| Test File | Changes Needed |
|---|---|
| `test/bloc/genre_bloc_test.dart` | Update `GenreLoading()` → `const GenreLoading()`, rename `CreateGenreEvent`→`CreateGenre`, add test for C1 fix |
| `test/bloc/auth_bloc_test.dart` | Add race condition test for C2 |
| `test/bloc/label_bloc_test.dart` | Update `LabelLoading()` assertions if M1 changes emit behavior, add H2 error-preservation test |
| `test/bloc/chapter_bloc_test.dart` | Update to use `ChapterRef` instead of `ChapterEntity` in events (H4) |
| `test/bloc/scan_bloc_test.dart` | Update `ScanCoverUploaded` constructor if M2 changes are applied |
| `test/bloc/profile_bloc_test.dart` | Verify M6 refactoring doesn't break any tests |

### New tests to add:

```dart
// test/bloc/genre_bloc_test.dart — C1 regression test:
test(
  'CreateGenre preserves existing genres after successful mutation',
  () async {
    // Setup: load genres first, then create
    // Verify: state is GenreLoaded with OLD genres + NEW genre
  },
);

// test/bloc/auth_bloc_test.dart — C2 regression test:
test(
  'External logout during manual logout does not duplicate LogoutRequested',
  () async {
    // Setup: trigger manual logout, fire signedOut stream event during it
    // Verify: logout() called only once
  },
);
```

---

## Phase 5: Verification & Cleanup

**Estimated time: 15 min**

### Verification checklist:

- [ ] `flutter analyze` — 0 errors, 0 warnings
- [ ] `flutter test` — all existing tests pass
- [ ] Manual test: Genre CRUD — no data loss after create/update/delete
- [ ] Manual test: Auth — logout works correctly, no duplicate events
- [ ] Manual test: Label CRUD — data preserved on error, no full reload
- [ ] Manual test: Chapter loading — chapters display correctly with ChapterRef
- [ ] Manual test: Theme — app respects system dark/light mode on startup
- [ ] Manual test: Scan cover upload — cover filename appears correctly
- [ ] Manual test: Profile — no spinner flash during mutations

### Cleanup:

- [ ] Remove any temporary comments added during investigation
- [ ] Ensure all TODOs have issue references
- [ ] Update any relevant documentation

---

## Summary Table

| Phase | Issues | Files Changed | Risk | Est. Time |
|---|---|---|---|---|
| Phase 0 (Critical) | C1, C2 | 2 | HIGH | 30 min |
| Phase 1 (High) | H1, H2, H3, H4 | 4–5 | MEDIUM | 45 min |
| Phase 2 (Medium) | M1–M6 | 8–10 | LOW | 40 min |
| Phase 3 (Low) | L1–L5 | 5–6 | VERY LOW | 20 min |
| Phase 4 (Tests) | Test updates | 5–6 | LOW | 30 min |
| Phase 5 (Verify) | Checklist | 0 | NONE | 15 min |
| **Total** | **17** | **~16 unique** | | **~2.75 hr** |

---

## Dependencies

```
C1 ──→ M1 (GenreBloc mutations)
C2 ──→ (independent)
H1 ──→ (independent)
H2 ──→ (independent)
H3 ──→ (independent, documentation only)
H4 ──→ (independent)
M1 ──→ depends on C1 being done first (removes GenreLoading from mutations)
M2 ──→ (independent)
M3 ──→ (independent)
M4 ──→ depends on M3 (same const changes)
M5 ──→ depends on genre_bloc_test updates
M6 ──→ (independent)
L1 ──→ (independent)
L2 ──→ (independent)
L3 ──→ (independent)
L4 ──→ (independent)
L5 ──→ covered by M3
```

**Critical path:** C1 → M1 → verify GenreBloc → tests

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| C1 fix breaks existing tests that expect `GenreLoading` during mutations | HIGH | MEDIUM | Update test expectations to not expect Loading during mutations |
| M5 rename causes compile errors from missed references | LOW | HIGH | Use IDE rename refactoring + `flutter analyze` |
| H4 `ChapterRef` change misses a call site | LOW | HIGH | `grep` confirmed only 2 call sites in `chapter_screen.dart` |
| L1 system brightness detection fails in tests | MEDIUM | LOW | Provide `initialBrightness` parameter for testability |
| Const constructor additions break existing const usage in tests | LOW | LOW | `const` is additive, never breaking |
