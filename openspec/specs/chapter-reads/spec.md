# Chapter Reads Specification

## Purpose

Track which chapters a user has read and display read status visually in TookScreen. This enables the "Continuar leyendo" feature to navigate to the last chapter read and gives users visual feedback of their reading progress.

## Requirements

### Requirement: DB table — chapter_reads

The system MUST create a table `chapter_reads` with:
- `user_id` (UUID, NOT NULL, FK → auth.users.id)
- `chapter_id` (INTEGER, NOT NULL, FK → chapters.id)
- `read_at` (TIMESTAMPTZ, NOT NULL, DEFAULT now())
- PRIMARY KEY (`user_id`, `chapter_id`)

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Table created | migration runs | checking schema | table exists with columns, FK constraints, composite PK |
| Duplicate read | user reads same chapter twice | second insert runs | no error — ON CONFLICT DO NOTHING |
| Unauthenticated user | no auth session | system tries to insert | insert is rejected by FK constraint |

### Requirement: Mark chapter as read

When a user scrolls past 80% of a chapter's content in ChapterScreen, the system MUST insert a row into `chapter_reads`. The mark MUST fire at most once per chapter per session.
(Previously: mark was triggered on initState — when the chapter first loaded, regardless of scroll.)

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Scroll past threshold | user scrolls to 80%+ of chapter content | scroll position crosses 80% | `chapter_reads` row inserted (one time) |
| Partial scroll | user scrolls to 50% then leaves | user navigates away | `chapter_reads` row NOT inserted |
| Already read | user already read the chapter (row exists) | user scrolls past 80% again | no duplicate row (PK conflict ignored) |
| Re-read from top | user reopens a read chapter, scrolls to 80% | scroll crosses 80% | no error — already-read is idempotent |

### Requirement: Get read chapter IDs by took

The system MUST provide a method to get all read chapter IDs for a given took and user.

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Has reads | user has read 3 chapters in took T | `getReadChapterIds(T, userId)` called | returns Set with 3 IDs |
| No reads | user hasn't read any chapters in took T | method called | returns empty Set |

### Requirement: TookScreen text color

TookScreen MUST display chapter titles with color based on read status:
- **White** (`Colors.white` or theme default) — chapter NOT in readIds set
- **Grey** (`Colors.grey`) — chapter IS in readIds set

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Mixed read status | took has 4 chapters, user read chapters 1 and 3 | TookScreen renders | chapters 1 and 3 show grey text, 2 and 4 show white text |
| All unread | user hasn't read any | screen renders | all titles show white text |
| All read | user read all chapters | screen renders | all titles show grey text |

### Requirement: RLS on chapter_reads

The system MUST enable Row-Level Security on `chapter_reads` with:
- SELECT: user can only read their own rows (`user_id = auth.uid()`)
- INSERT: user can only insert their own rows (`user_id = auth.uid()`)
- No UPDATE or DELETE policies needed (PK conflict handles re-reads)

| Scenario | GIVEN | WHEN | THEN |
|----------|-------|------|------|
| Read own | user requests their reads | policy evaluated | rows returned |
| Read others | user requests another user's reads | policy evaluated | empty set returned |
