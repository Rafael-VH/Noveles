# book-detail-ui Specification

## Purpose

Define el comportamiento e interfaz visual desarticulada en slivers de `BookScreen` en la aplicación Noveles, reemplazando contenedores rígidos por componentes sliver altamente personalizables.

## Requirements

### Requirement: Granular Sliver Metadata Display

The system SHALL display book metadata (Publicado, Tipo, País, Estado, Tomos, Capítulos) as individual modular cards within a dedicated sliver layout instead of a single monolithic container.

#### Scenario: Displaying metadata cards in light/dark mode
- GIVEN a book entity loaded into `BookScreen`
- WHEN the screen renders the details tab
- THEN each metadata item MUST render as a distinct card with an accent icon/tag and responsive layout
- AND MUST NOT be wrapped in a single rigid multi-cell container.

### Requirement: Segmented Tab Sliver Navigation

The system MUST provide a `SliverPersistentHeader` containing a styled segmented control allowing the user to switch seamlessly between "Información" and "Tomos & Capítulos".

#### Scenario: Switching tabs in BookScreen
- GIVEN `BookScreen` is rendered
- WHEN the user taps on "Tomos & Capítulos"
- THEN the scroll view MUST smoothly present the `BookTookList` section
- AND WHEN the user taps on "Información", it MUST present the description, metadata slivers, and genres.

### Requirement: Quick Action Bar

The system SHALL present a prominent Action Bar containing a primary "Empezar / Continuar Lectura" button alongside the interactive `FavoriteButton`.

#### Scenario: Tapping primary read button
- GIVEN a book with available chapters
- WHEN the user taps the primary action button
- THEN the system MUST open `ChapterScreen` for the first or latest unread chapter.
