# Spec: Analytics Dashboard (DB Infrastructure)

> **Type**: Full spec — new capability
> **Change**: `admin-panel-improvements`

## Purpose

Create the database infrastructure for book view analytics: a `book_views` table with RLS policies and indexes. No analytics UI — only the skeleton screen. The table is designed for future aggregation queries.

## Requirements

### REQ-AD-1: book_views table
**Given** a migration is run  
**When** inspecting the database schema  
**Then** a `book_views` table exists with columns: `id` (BIGINT PK generated always as identity), `book_id` (BIGINT NOT NULL FK → books.id), `viewed_at` (timestamptz, default now())

### REQ-AD-2: RLS policies
**Given** RLS is enabled on `book_views`  
**When** an admin user inserts a row  
**Then** the insert succeeds (INSERT policy checks `is_admin()`)  
**And** when an admin user SELECTs, they see all rows (SELECT policy checks `is_admin()`)

### REQ-AD-3: Indexes
**Given** the migration has run  
**When** checking indexes  
**Then** an index exists on `book_views(book_id)`  
**And** an index on `book_views(viewed_at)`  
**And** a composite index exists on `book_views(book_id, viewed_at)`

### REQ-AD-4: Analytics skeleton screen
**Given** the admin navigates to Analytics  
**When** the screen renders  
**Then** it displays an icon and "Próximamente" text as placeholder
