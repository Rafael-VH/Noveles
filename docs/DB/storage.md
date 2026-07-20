# Storage

> 3 buckets: avatars, covers, chapters.
> All buckets have public read access.

## Buckets

### avatars

| Property | Value |
| -------- | ----- |
| Public | ✅ Yes |
| File Size Limit | None |
| Allowed MIME Types | Any |

**Purpose**: User profile pictures.
**Folder Structure**: `{user_id}/{filename}`

---

### covers

| Property | Value |
| -------- | ----- |
| Public | ✅ Yes |
| File Size Limit | 50 MB |
| Allowed MIME Types | image/png, image/jpeg, image/webp |

**Purpose**: Book cover images.
**Folder Structure**: `{user_id}/{timestamp}.{ext}`

---

### chapters

| Property | Value |
| -------- | ----- |
| Public | ✅ Yes |
| File Size Limit | 10 MB |
| Allowed MIME Types | text/plain |

**Purpose**: Chapter content files.
**Folder Structure**: `{user_id}/{timestamp}.{ext}`

---

## RLS Policies

### covers bucket

| Operation | Policy Name | Condition |
| --------- | ----------- | --------- |
| INSERT | Covers: authenticated insert own folder | `bucket_id = 'covers' AND auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text` |
| UPDATE | Covers: authenticated update own folder | Same as INSERT |
| DELETE | Covers: authenticated delete own folder | Same as INSERT |

### chapters bucket

| Operation | Policy Name | Condition |
| --------- | ----------- | --------- |
| INSERT | Chapters: authenticated insert own folder | `bucket_id = 'chapters' AND auth.role() = 'authenticated' AND (storage.foldername(name))[1] = auth.uid()::text` |
| UPDATE | Chapters: authenticated update own folder | Same as INSERT |
| DELETE | Chapters: authenticated delete own folder | Same as INSERT |

---

## Folder Structure

```text
covers/
  {user_id}/
    {timestamp}.jpg
    {timestamp}.png

chapters/
  {user_id}/
    {timestamp}.txt

avatars/
  {user_id}/
    {filename}
```

**Key Points**:

- All uploads are prefixed with `{user_id}/` — users can only access their own folder
- Existing files in root (without user prefix) are still readable but cannot be modified
- New uploads always go to user-specific folders

---

## Security Notes

### ✅ Strong

- Upload restricted to authenticated users
- Users can only upload to their own folder (`{user_id}/`)
- Users can only delete their own files
- MIME type validation on covers (images only) and chapters (text only)
- File size limits enforced

### ⚠️ Monitor

- Buckets are public — anyone with the URL can read files
- No rate limiting on uploads
- No virus scanning on uploaded files
