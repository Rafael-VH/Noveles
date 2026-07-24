# Reading Progress Specification

## Purpose

Show the user where they are in the book ("Chapter X of Y") and persist scroll position per chapter so they resume exactly where they left off.

## Requirements

### Requirement: Chapter position indicator

The reader MUST display a "Chapter {N} of {M}" label that updates when the user swipes between pages in the PageView.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| First chapter | book has 12 chapters, user is on page 0 | reader renders | label reads "Chapter 1 of 12" |
| After swipe | user swipes to page 5 | page transition completes | label reads "Chapter 6 of 12" |
| Single chapter | book has 1 chapter | reader renders | label reads "Chapter 1 of 1" |

### Requirement: Scroll position persistence

The system SHALL save the scroll offset of each chapter when the user navigates away and restore it when returning to that chapter.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Save on navigate | user is at offset 450 in chapter 3 | user swipes to chapter 4 | offset 450 is stored for chapter 3 |
| Restore on return | chapter 3 has saved offset 450 | user swipes back to chapter 3 | chapter 3 content scrolls to offset 450 |
| First visit | chapter has no saved offset | user opens it | content starts at offset 0 (top) |
| No saved offset after scroll | user scrolls less than 50px | user navigates away | system SHOULD NOT save (debounce threshold) |

### Constraints

- Save operations MUST be debounced (at most once every 2s) to avoid jank on dispose.
- Scroll position data SHALL be stored per user + per chapter, in memory for session, persisted to local storage on navigation away.
- "Chapter X of Y" SHALL NOT block or overlap reading content.

### Acceptance Criteria

- [ ] Position label updates on every PageView page change.
- [ ] Scrolling a chapter, leaving, and returning restores the exact offset.
- [ ] Saving does not cause scroll jank or frame drops.
