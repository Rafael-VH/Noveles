# Supabase Database Audit

> Audit date: 2026-07-20
> Migrations applied: 31 (last: `20260720223843_create_analytics_functions`)

## Overview

| Metric | Value |
| -------- | ------- |
| Tables | 11 (all with RLS enabled) |
| SQL Functions | 9 (all SECURITY DEFINER) |
| Storage Buckets | 3 |
| Total RLS Policies | 63 |

## Quick Links

- [Tables & Schema](tables.md) — columns, types, code mapping, required
policies
- [RLS Policies](rls-policies.md) — all 63 policies with conditions
- [SQL Functions](sql-functions.md) — 9 SECURITY DEFINER functions
- [Storage](storage.md) — 3 buckets, folder structure, RLS

## Role Model

| Role | Access Level |
| ------ | ------------- |
| `admin` | Full access — CRUD on all tables, read analytics |
| `scan` | Content creator — CRUD on own content (`created_by = auth.uid()`) |
| `user` | Reader — read visible books, manage own favorites |
| `suspended` | No access — blocked at app level (routing guard) |

## Migration History

| Version | Name | Date | Purpose |
| --------- | ------ | ------ | --------- |
| 20260514220000 | initial_schema | May 14 | Core tables (books,authors,gen... |
| 20260515000000 | authors_and_constraints | May 15 | Author constraints |
| 20260515161849 | profiles_and_auth | May 15 | Auth + profiles |
| 20260515170000 | profiles_extended | May 15 | Extended profile fields |
| 20260515200000 | storage_migration | May 15 | Storage buckets |
| 20260515210000 | admin_roles | May 15 | Admin role system |
| 20260515230000 | fix_admin_consolidation | May 15 | Admin consolidation |
| 20260515235000 | fix_storage_buckets | May 15 | Storage bucket fixes |
| 20260517205000 | fix_profiles_rls_recursion | May 17 | RLS recursion fix |
| 20260518010000 | admin_ownership | May 18 | Admin ownership |
| 20260519000000 | fix_tooks_chapters_rls | May 19 | Took/chapter RLS |
| 20260520000000 | rename_admin_to_scan | May 20 | Rename admin → scan |
| 20260520010000 | add_admin_role | May 20 | Add admin role |
| 20260520020000 | labels | May 20 | Labels system |
| 20260520171320 | storage_authenticated_u... | May 20 | Authenticated uploads |
| 20260521000000 | fix_scan_rls_own_books | May 21 | Scan RLS own books |
| 20260521200000 | audit_plan_fixes | May 21 | Audit fixes |
| 20260522000000 | audit_fixes | May 22 | Audit fixes |
| 20260523000000 | admin_panels | May 23 | Admin panels + book_views |
| 20260524000000 | audit_fixes_v2 | May 24 | Audit fixes v2 |
| 20260524100000 | profiles_rls_insert_update | May 24 | Profile RLS |
| 20260524110000 | fix_books_rls_scan_visibility | May 24 | Book visibility |
| 20260615000000 | audit_fixes_v4 | Jun 15 | Audit fixes v4 |
| 20260616000001 | fix_storage_rls_and_se... | Jun 16 | Storage RLS + security |
| 20260617000001 | fix_sequences_after_seed | Jun 17 | Sequence fixes |
| 20260617153406 | fix_chapters_storage_rls | Jun 17 | Chapter storage RLS |
| 20260720010000 | add_is_user_helper | Jul 20 | `is_user()` function |
| 20260720020000 | fix_storage_rls_ownership | Jul 20 | Storage folder rest... |
| 20260720030000 | create_user_favorites | Jul 20 | Favorites table |
| 20260720040000 | add_suspended_role | Jul 20 | Suspended role constraint |
| 20260720050000 | create_analytics_func... | Jul 20 | Analytics SQL functions |
