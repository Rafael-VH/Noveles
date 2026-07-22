# Tasks: Main Screen Views Sections

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated changed lines | 900–1300 |
| 400-line budget risk | Low |
| Chained PRs recommended | No |
| Suggested split | Single PR (user accepted sin límite) |
| Delivery strategy | auto-forecast |
| Chain strategy | size-exception |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | DB migration + Repo methods + Use cases | PR 1 | Foundation layer, no UI |
| 2 | BLoCs + Widgets + Integration | PR 1 | Builds on unit 1 |

## Phase 1: DB + Repository + Use Cases

- [ ] 1.1 Create `supabase/migrations/YYYYMMDD_chapter_reads.sql` — `chapter_reads` table + RPCs `get_user_recent_views` + `get_most_viewed_books` (both SECURITY DEFINER, STABLE, RETURNS TABLE)
- [ ] 1.2 Add `getRecentViews(String userId)` + `getMostViewedBooks()` to `BookRepository` abstract interface
- [ ] 1.3 Implement both in `BookRepositoryImpl` — `rpc()` call + follow-up `.select()` with `BookModel.fromJson`
- [ ] 1.4 Add `markChapterAsRead(int chapterId, String userId)` + `getReadChapterIds(int tookId, String userId)` to `ChapterRepository` abstract interface
- [ ] 1.5 Implement both in `ChapterRepositoryImpl` — direct `chapter_reads` select/insert with RLS
- [ ] 1.6 Create `GetRecentViews` in `books/domain/` — delegates to `repository.getRecentViews(userId)`, null-safe on userId
- [ ] 1.7 Create `GetMostViewedBooks` in `books/domain/` — delegates to `repository.getMostViewedBooks()`
- [ ] 1.8 Create `MarkChapterAsRead` in `chapters/domain/` — delegates to `repository.markChapterAsRead(chapterId, userId)`
- [ ] 1.9 Create `GetReadChapterIds` in `chapters/domain/` — delegates to `repository.getReadChapterIds(tookId, userId)`
- [ ] 1.10 Register new use cases in `injection_books.dart` + `injection_chapters.dart`

## Phase 2: BLoCs

- [ ] 2.1 Create `recent_views_event.dart` (LoadRecentViews) + `recent_views_state.dart` (Initial, Loading, Loaded, Empty, Error) + `recent_views_bloc.dart` in `books/presentation/bloc/`
- [ ] 2.2 Create `popular_views_event.dart` (LoadPopularViews) + `popular_views_state.dart` (same states) + `popular_views_bloc.dart` in `books/presentation/bloc/`
- [ ] 2.3 Register `RecentViewsBloc` + `PopularViewsBloc` (Factory) in `injection_books.dart`

## Phase 3: Widgets

- [ ] 3.1 Create `SectionRecentViews` in `app/presentation/widgets/` — BlocConsumer, horizontal scroll, `BookCardVertical` cards, `SizedBox.shrink()` when empty. Tap → ChapterScreen (last chapter) or BookScreen (fallback)
- [ ] 3.2 Create `SectionMasVistos` in `app/presentation/widgets/` — same pattern, tap → BookScreen
- [ ] 3.3 Modify `TookScreen` — add `GetReadChapterIds` call on init (FutureBuilder), color `ListTile` title: grey if read, white if not
- [ ] 3.4 Modify `ChapterScreen` — call `MarkChapterAsRead(chapterId, userId)` in initState

## Phase 4: Integration

- [ ] 4.1 Add `BlocProvider<RecentViewsBloc>` + `BlocProvider<PopularViewsBloc>` to `MainScreen.build` MultiBlocProvider
- [ ] 4.2 Add `SectionRecentViews` (after carousel) + `SectionMasVistos` (after Novedades) in `_buildContent` CustomScrollView

## Phase 5: Tests

- [ ] 5.1 Unit tests in `test/use_cases/` — GetRecentViews, GetMostViewedBooks, MarkChapterAsRead, GetReadChapterIds (mock repositories, verify delegate)
- [ ] 5.2 Bloc tests in `test/bloc/` — RecentViewsBloc + PopularViewsBloc (blocTest, verify state sequence per spec scenarios)
- [ ] 5.3 Widget tests in `test/widgets/` — SectionRecentViews + SectionMasVistos (inject mocked bloc state, verify cards / empty / error)
- [ ] 5.4 Widget test: TookScreen coloring — inject readIds set, verify ListTile text color (grey / white)
- [ ] 5.5 Widget test: ChapterScreen — verify markChapterAsRead called on init
