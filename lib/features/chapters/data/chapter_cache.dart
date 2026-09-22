import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:noveles/core/utils/logger.dart';

class ChapterCache {
  static const Duration _ttl = Duration(days: 7);

  static Future<Directory> _cacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/chapters_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<bool> has(String filename) async {
    try {
      final dir = await _cacheDir();
      return await File('${dir.path}/$filename').exists();
    } catch (e) {
      return false;
    }
  }

  static Future<String?> read(String filename) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/$filename');
      if (!await file.exists()) return null;

      // TTL check: remove stale entries older than 7 days
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      if (age > _ttl) {
        await file.delete();
        return null;
      }

      return utf8.decode(await file.readAsBytes(), allowMalformed: true);
    } catch (e) {
      AppLogger.warning('ChapterCache.read error for $filename: $e');
      return null;
    }
  }

  static Future<void> save(String filename, List<int> bytes) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
    } catch (e) {
      AppLogger.warning('ChapterCache.save error for $filename: $e');
    }
  }

  static Future<void> clear() async {
    try {
      final dir = await _cacheDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    } catch (e) {
      AppLogger.warning('ChapterCache.clear error: $e');
    }
  }
}
