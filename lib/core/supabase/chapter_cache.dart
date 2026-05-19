import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ChapterCache {
  static Future<Directory> _cacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/chapters_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<bool> has(String filename) async {
    final dir = await _cacheDir();
    return File('${dir.path}/$filename').exists();
  }

  static Future<String?> read(String filename) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/$filename');
      if (!await file.exists()) return null;
      return utf8.decode(await file.readAsBytes());
    } catch (e) {
      debugPrint('ChapterCache.read error for $filename: $e');
      return null;
    }
  }

  static Future<void> save(String filename, List<int> bytes) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
    } catch (e) {
      debugPrint('ChapterCache.save error for $filename: $e');
    }
  }
}
