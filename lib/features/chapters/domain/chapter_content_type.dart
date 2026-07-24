/// Defines how a chapter's content is stored.
///
/// - [inline]: The content field contains the actual text to display.
/// - [storagePath]: The content field is a path to a file in Supabase storage.
enum ChapterContentType {
  inline,
  storagePath,
}
