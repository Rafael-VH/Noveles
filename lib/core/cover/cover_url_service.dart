import 'package:noveles/core/backend/storage_gateway.dart';
import 'package:noveles/core/constants/storage_constants.dart';

class CoverUrlService {
  final StorageGateway _storage;

  CoverUrlService(this._storage);

  String call(String? cover) {
    if (cover == null || cover.isEmpty) return '';
    if (cover.startsWith('http')) return cover;
    return _storage.publicUrl(StorageConstants.coversBucket, cover);
  }
}
