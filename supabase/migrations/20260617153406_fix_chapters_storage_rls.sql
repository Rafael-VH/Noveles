-- Allow authenticated users (scan, admin) to upload and manage chapter content files
-- Mirror the same policies already applied to the covers bucket in 20260520171320

CREATE POLICY "Chapters authenticated insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'chapters'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "Chapters authenticated update"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'chapters' AND auth.role() = 'authenticated');

CREATE POLICY "Chapters authenticated delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'chapters' AND auth.role() = 'authenticated');
