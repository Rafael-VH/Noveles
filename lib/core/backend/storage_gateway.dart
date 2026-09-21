import 'dart:io';

/// Port for binary object storage.
///
/// Kept separate from [DataGateway] on purpose: storage is usually a different
/// system (an S3-compatible service) and moving it is an independent decision
/// from moving the database.
abstract class StorageGateway {
  /// Upload [file] as [path] inside [bucket].
  ///
  /// When [upsert] is true an existing object at [path] is overwritten.
  Future<void> upload(
    String bucket,
    String path,
    File file, {
    bool upsert = false,
  });

  /// Download the bytes stored at [path] inside [bucket].
  Future<List<int>> download(String bucket, String path);

  /// Remove every path in [paths] from [bucket].
  Future<void> remove(String bucket, List<String> paths);

  /// Public URL for [path] inside [bucket].
  String publicUrl(String bucket, String path);

  /// Object path encoded in a previously issued public URL, or `null` when the
  /// URL does not belong to [bucket].
  ///
  /// Exists because rows historically persisted whole public URLs; adapters
  /// know their own URL shape, so URL parsing does not belong in repositories.
  String? pathFromUrl(String bucket, String url);
}
