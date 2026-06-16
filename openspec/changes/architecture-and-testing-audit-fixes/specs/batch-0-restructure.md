# Spec: Batch 0 — Feature-Grouped Directory Restructure

## Domain
architecture/restructure

## Purpose

Mechanically restructure flat `data/` and `domain/` directories into feature-grouped subdirectories mirroring the already-structured `presentation/` layout. **Zero behavior changes.** Only file paths and import statements are modified.

## Requirements

### Requirement: Flat directories replaced by feature-grouped structure

The system MUST replace flat `lib/features/data/models/`, `lib/features/data/repositories/`, `lib/features/domain/entities/`, `lib/features/domain/repositories/`, `lib/features/domain/use_cases/`, and `lib/features/domain/helpers/` directories with per-feature subdirectories under `lib/features/data/{feature}/` and `lib/features/domain/{feature}/`.

#### Scenario: Data models moved to feature groups

- GIVEN the current flat `lib/features/data/models/` directory
- WHEN all model files are moved to their feature subdirectory under `lib/features/data/{feature}/`
- THEN `book_model.dart` MUST reside in `lib/features/data/books/`
- AND `chapter_model.dart` MUST reside in `lib/features/data/chapters/`
- AND `genre_model.dart` MUST reside in `lib/features/data/genres/`
- AND `label_model.dart` MUST reside in `lib/features/data/labels/`
- AND `took_model.dart` MUST reside in `lib/features/data/tooks/`
- AND `user_model.dart` MUST reside in `lib/features/data/profiles/`

#### Scenario: Data repositories moved to feature groups

- GIVEN the current flat `lib/features/data/repositories/` directory
- WHEN all repository implementation files are moved to their feature subdirectory
- THEN `auth_repository_impl.dart` MUST reside in `lib/features/data/auth/`
- AND `book_repository_impl.dart` MUST reside in `lib/features/data/books/`
- AND `chapter_repository_impl.dart` MUST reside in `lib/features/data/chapters/`
- AND `genre_repository_impl.dart` MUST reside in `lib/features/data/genres/`
- AND `label_repository_impl.dart` MUST reside in `lib/features/data/labels/`
- AND `profiles_repository_impl.dart` MUST reside in `lib/features/data/profiles/`
- AND `took_repository_impl.dart` MUST reside in `lib/features/data/tooks/`

#### Scenario: Domain entities moved to feature groups

- GIVEN the current flat `lib/features/domain/entities/` directory
- WHEN all entity files are moved to their feature subdirectory
- THEN `book_entity.dart` MUST reside in `lib/features/domain/books/`
- AND `chapter_entity.dart` MUST reside in `lib/features/domain/chapters/`
- AND `genre_entity.dart` MUST reside in `lib/features/domain/genres/`
- AND `label_entity.dart` MUST reside in `lib/features/domain/labels/`
- AND `took_entity.dart` MUST reside in `lib/features/domain/tooks/`
- AND `user_entity.dart` MUST reside in `lib/features/domain/profiles/`

#### Scenario: Domain repositories moved to feature groups

- GIVEN the current flat `lib/features/domain/repositories/` directory
- WHEN all repository interface files are moved to their feature subdirectory
- THEN `auth_repository.dart` MUST reside in `lib/features/domain/auth/`
- AND `book_repository.dart` MUST reside in `lib/features/domain/books/`
- AND `chapter_repository.dart` MUST reside in `lib/features/domain/chapters/`
- AND `genre_repository.dart` MUST reside in `lib/features/domain/genres/`
- AND `label_repository.dart` MUST reside in `lib/features/domain/labels/`
- AND `profiles_repository.dart` MUST reside in `lib/features/domain/profiles/`
- AND `took_repository.dart` MUST reside in `lib/features/domain/tooks/`

#### Scenario: Domain use cases moved to feature groups

- GIVEN the current flat `lib/features/domain/use_cases/` directory
- WHEN all use case files are moved to their feature subdirectory
- THEN each use case file MUST reside in `lib/features/domain/{feature}/` matching its domain concept
- AND feature groupings MUST follow the mapping in the design document

#### Scenario: Domain helpers absorbed into feature groups

- GIVEN `lib/features/domain/helpers/text_stats.dart`
- WHEN it is moved
- THEN `text_stats.dart` MUST reside in `lib/features/domain/books/` (used by `ChapterScreen` for book text statistics)

### Requirement: Per-feature DI files

The system MUST split the single `lib/core/di/injection.dart` into per-feature DI files and a main orchestrator.

#### Scenario: Feature DI files created

- GIVEN the current monolithic `injection.dart`
- WHEN it is split
- THEN per-feature files MUST be created at `lib/core/di/injection_{feature}.dart` for each of: auth, books, chapters, genres, labels, profiles, tooks, scan, admin
- AND the main `injection.dart` MUST import and call each feature's `init{Feature}Dependencies()` function
- AND all DI registrations MUST be identical — no registration added, removed, or reordered

### Requirement: All imports updated

Every Dart file with an import referencing the old flat paths MUST be updated to reference the new feature-grouped paths.

#### Scenario: Barrels rewritten per feature

- GIVEN existing barrel files (`models.dart`, `entities.dart`, `repositories.dart`, `use_cases.dart`)
- WHEN they are replaced
- THEN each feature directory MUST have its own barrel file exporting local types
- AND cross-feature imports from barrels MUST resolve correctly (e.g., auth use cases importing `UserEntity` from `domain/profiles/`)

#### Scenario: Cross-feature imports resolve

- GIVEN entities or types used across feature boundaries (e.g., `UserEntity` used by both auth and profiles)
- WHEN the file moves to `domain/profiles/`
- THEN all files in other features importing `UserEntity` MUST update their import path to `features/domain/profiles/user_entity.dart` or the profiles barrel

### Requirement: No behavior changes

The restructure MUST NOT alter any runtime behavior.

#### Scenario: `dart analyze` passes with zero errors

- GIVEN the restructured project
- WHEN `dart analyze` is executed
- THEN it MUST exit with zero errors
- AND zero warnings

#### Scenario: All existing tests pass

- GIVEN the restructured project
- WHEN `flutter test` is executed
- THEN all existing tests MUST pass with no failures

#### Scenario: Old directories are empty and removable

- GIVEN all files have been moved
- WHEN the old flat directories are checked
- THEN `lib/features/data/models/`, `lib/features/data/repositories/`, `lib/features/domain/entities/`, `lib/features/domain/repositories/`, `lib/features/domain/use_cases/`, and `lib/features/domain/helpers/` MUST be empty
- AND they MAY be deleted
