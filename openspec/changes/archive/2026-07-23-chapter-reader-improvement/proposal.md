# Proposal: Chapter Reader Improvement

## Intent

Fix performance, visual, and UX issues in the chapter reading flow (TookScreen → ChapterScreen). The current implementation loads all chapters upfront, has hardcoded typography, no reading settings, broken scroll controllers, and fragile storage-path heuristics.

## Scope

### In Scope
1. **TookScreen visual + fix**: cover image in styled header, `_loadingReadIds` loading indicator, read status on chapter list, proper took title + number.
2. **Lazy chapter loading**: load current + N adjacent chapters, not all at once.
3. **PageController as instance variable**: stop recreating it on every build.
4. **Per-page ScrollController**: each PageView page gets its own controller.
5. **Reading typography from theme**: remove hardcoded Arial 14px; use theme with proper line-height.
6. **"Chapter X of Y" indicator**: position-aware reading progress.
7. **Mark as read on scroll completion**: 80% scroll threshold, not initState.
8. **Font size control**: user-configurable font size in a reading settings overlay.
9. **Reading mode toggle**: sepia and night mode support.
10. **Replace `_isStoragePath` with explicit content type**: use an enum/flag on the entity instead of string heuristics.
11. **Scroll position persistence per chapter**: save/restore scroll offset per chapter.

### Out of Scope
- Bookmarking or annotations — future feature.
- Full-text search within chapters.
- Offline-first chapter sync or background preload.
- TTS / read-aloud.
- Chapter progress sync across devices (future).

## Capabilities

### New Capabilities
- `reading-settings`: font size controls and reading mode toggle (sepia/night).
- `reading-progress`: "Chapter X of Y" indicator, scroll position persistence.

### Modified Capabilities
- `chapter-reads`: mark-as-read trigger moves from initState to 80% scroll threshold (behavior change).

## Approach

Refactor in 3 layers:

1. **Architecture fix (Bloc)**: replace `Future.wait` with lazy loading — emit loaded chapters incrementally. Add `next`/`previous` events for adjacent chapter preload.
2. **Screen refactor (ChapterScreen)**: PageController as instance var, per-page ScrollControllers, scroll-aware mark-as-read, reading settings overlay with font size + mode toggle.
3. **Visual polish (TookScreen + ChapterScreen)**: styled took header with cover, read-status indicators, position tracker.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/.../chapter_bloc.dart` | Modified | Replace Future.wait with lazy load + preload adjacent |
| `lib/.../chapter_state.dart` | Modified | Add incremental loading states |
| `lib/.../chapter_event.dart` | Modified | Add preload adjacent events |
| `lib/.../chapter_screen.dart` | Modified | PageController fix, per-page ScrollController, scroll-aware mark, reading settings |
| `lib/.../took_screen.dart` | Modified | Cover header, loading indicator, styled chapter list |
| `lib/.../chapter_repository_impl.dart` | Modified | Replace `_isStoragePath` with explicit content type flag |
| `lib/.../chapter_entity.dart` | Modified | Add content type flag |
| `lib/.../chapter_cache.dart` | Modified | Add TTL / stale-cache cleanup |
| `lib/.../chapter_model.dart` | Modified | Serialize content type |
| `lib/core/di/injection_chapters.dart` | Modified | May need new use case registrations |
| `openspec/specs/chapter-reads/spec.md` | Modified | Update mark-as-read trigger scenario |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Scroll position persistence on dispose causes jank | Medium | Debounce saves; use async gap |
| Lazy loading adds complexity to PageView swipe | Medium | Keep N+2 buffer, clear on page change |
| Sepia/night mode may clash with existing theme | Low | Limit to chapter reader scope; inherit theme colors as base |

## Rollback Plan

Revert to most recent git tag or commit before changes. Files are isolated to 8 files in `lib/` — revert is straightforward. If the lazy-load approach causes regressions, fallback to loading chapters in batches of 10 instead of single-file.

## Dependencies

- Existing `chapter-reads` spec (mark-as-read behavior change needs spec update).
- `CoverUrlService` already exists for cover image rendering.

## Success Criteria

- [ ] Book with 200+ chapters opens ChapterScreen without timeout or OOM.
- [ ] PageController is created once, not on every build.
- [ ] Each PageView page scrolls independently.
- [ ] Chapter marks as read only after 80% scroll — not on initState.
- [ ] Font size changes reflect immediately in chapter text.
- [ ] Sepia/night mode changes background + text color in reader.
- [ ] "Chapter X of Y" updates correctly on page swipe.
- [ ] `_isStoragePath` is removed; content type is explicit.
- [ ] TookScreen shows cover image, loading indicator, styled list.
