-- Allow authenticated users (scan, admin) to upload and manage covers
CREATE POLICY "Covers authenticated insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'covers'
    AND auth.role() = 'authenticated'
  );

CREATE POLICY "Covers authenticated update"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'covers' AND auth.role() = 'authenticated');

CREATE POLICY "Covers authenticated delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'covers' AND auth.role() = 'authenticated');
