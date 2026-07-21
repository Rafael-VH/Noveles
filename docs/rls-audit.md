# RLS Audit — 2026-07-20

## Security Advisors

| Issue | Table/Function | Severity | Status |
| ------- | --------------- | ---------- | -------- |
| RLS Policy Always True | `book_views` INSERT | WARN | Pre-exists — `WITH CHECK (true)` allows any authenticated user to insert views |
| Public Bucket Allows Listing | `avatars`, `chapters`, `covers` | WARN | Pre-exists — public buckets expose file listing |
| SECURITY DEFINER callable by anon | `handle_new_user`, `is_admin`, `is_scan`, `is_admin_or_scan`, `rls_auto_enable` | WARN | Pre-exists — these functions are intentionally SECURITY DEFINER for role checks |
| Leaked Password Protection | Auth settings | WARN | Pre-exists — recommended to enable in Supabase dashboard |

## Admin RLS Verification

| Table | SELECT | INSERT | UPDATE | DELETE | Status |
| ------- | -------- | -------- | -------- | -------- | -------- |
| `books` | `is_admin()` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verified |
| `profiles` | `is_admin()` | own only | `is_admin()` | — | ✅ No DELETE (intentional — suspend only) |
| `genres` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verified |
| `tooks` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verified |
| `chapters` | `true` | `is_admin()` | `is_admin()` | `is_admin()` | ✅ Verified |
| `book_views` | `is_admin()` | `true` | — | — | ⚠️ INSERT overly permissive |

## Notes

- `is_admin()` is SECURITY DEFINER with `SET search_path = ''` ✅
- No DELETE policy on `profiles` — intentional for Phase2 decision (suspend
  only)
- All WARNs are pre-existing, no new issues from Phase1 changes
