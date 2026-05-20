# Spec: Genre Management (Admin)

> **Type**: Full spec — new capability
> **Change**: `admin-panel-improvements`

## Purpose

Provide admin-only CRUD UI for genres. Admins can list, add, edit, and delete genres from a dedicated screen. Uses existing `GenreRepository` (which already has `createGenre`, `updateGenre`, `deleteGenre`) but exposed via a new `AdminGenreBloc` to avoid shadowing the existing user-facing `GenreBloc`.

## Requirements

### REQ-GM-1: Admin genre list
**Given** the admin navigates to the genre management screen  
**When** the screen loads  
**Then** all genres are displayed in a list with name and description  
**And** each item has edit and delete action buttons

### REQ-GM-2: Add genre
**Given** the admin is on the genre management screen  
**When** they tap "Add genre" and submit name + description  
**Then** the new genre appears in the list  
**And** a success message is shown

### REQ-GM-3: Edit genre
**Given** the admin taps edit on a genre  
**When** they modify name or description and save  
**Then** the genre is updated in the list  
**And** a success message is shown

### REQ-GM-4: Delete genre
**Given** the admin taps delete on a genre  
**When** they confirm the deletion dialog  
**Then** the genre is removed from the list  
**And** a success message is shown

### REQ-GM-5: Error handling
**Given** a Supabase operation fails  
**When** the admin performs any CRUD action  
**Then** an error message is displayed  
**And** the genre list state is preserved
