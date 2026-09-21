import 'dart:io';

import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [StorageGateway] backed by Supabase Storage.
///
/// Supabase Storage is S3-compatible, so moving object storage is an
/// independent decision from moving the database: a second adapter over S3
/// would not touch the feature repositories.
class SupabaseStorageGateway implements StorageGateway {
  final SupabaseClient _client;

  SupabaseStorageGateway(this._client);

  @override
  Future<void> upload(
    String bucket,
    String path,
    File file, {
    bool upsert = false,
  }) {
    final storage = _client.storage.from(bucket);
    if (upsert) {
      return storage.upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
    }
    return storage.upload(path, file);
  }

  @override
  Future<List<int>> download(String bucket, String path) =>
      _client.storage.from(bucket).download(path);

  @override
  Future<void> remove(String bucket, List<String> paths) =>
      _client.storage.from(bucket).remove(paths);

  @override
  String publicUrl(String bucket, String path) =>
      _client.storage.from(bucket).getPublicUrl(path);

  @override
  String? pathFromUrl(String bucket, String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;
    final segments = uri.pathSegments;
    final bucketIndex = segments.indexOf(bucket);
    if (bucketIndex == -1) return null;
    return segments.sublist(bucketIndex + 1).join('/');
  }
}
