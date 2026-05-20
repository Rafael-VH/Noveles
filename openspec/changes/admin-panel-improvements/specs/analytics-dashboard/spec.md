# Spec: Analytics Dashboard (DB Infrastructure)

> **Type**: Full spec — new capability
> **Change**: `admin-panel-improvements`

## Purpose

Create the database infrastructure for book view analytics: a `book_views` table with RLS policies and indexes. No analytics UI — only the skeleton screen with a time-range selector placeholder. The table is designed for future aggregation queries.

## Requirements

### REQ-AD-1: book_views table
**Given** a migration is run  
**When** inspecting the database schema  
**Then** a `book_views` table exists with columns: `id` (SERIAL PK), `book_id` (FK → books.id), `user_id` (UUID nullable, refers to auth.users), `viewed_at` (timestamptz, default now())

### REQ-AD-2: RLS policies
**Given** RLS is enabled on `book_views`  
**When** an authenticated user inserts a row  
**Then** the insert succeeds (INSERT policy for authenticated users)  
**And** when a non-admin user SELECTs, they get only their own rows  
**And** when an admin SELECTs, they see all rows

### REQ-AD-3: Indexes
**Given** the migration has run  
**When** checking indexes  
**Then** a composite index exists on `book_views(book_id, viewed_at)`  
**And** an index on `book_views(user_id)` exists

### REQ-AD-4: Analytics skeleton screen
**Given** the admin navigates to Analytics  
**When** the screen renders  
**Then** it displays a time-range selector (day/week/month/6m/year)  
**And** placeholder content indicating data will appear here
