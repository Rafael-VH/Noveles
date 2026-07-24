import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/features/chapters/data/chapter_cache.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('chapter_cache_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ChapterCache.clear()', () {
    test('removes all cached files', () async {
      await ChapterCache.save('test1.txt', [1, 2, 3]);
      await ChapterCache.save('test2.txt', [4, 5, 6]);

      expect(await ChapterCache.has('test1.txt'), isTrue);
      expect(await ChapterCache.has('test2.txt'), isTrue);

      await ChapterCache.clear();

      expect(await ChapterCache.has('test1.txt'), isFalse);
      expect(await ChapterCache.has('test2.txt'), isFalse);
    });

    test('does not throw if directory does not exist', () async {
      final cacheDir = Directory('${tempDir.path}/chapters_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      await ChapterCache.clear();
      // Should not throw — no assertion needed beyond completing
    });

    test('leaves save/has/read usable after clear', () async {
      await ChapterCache.clear();
      await ChapterCache.save('post_clear.txt', [65, 66, 67]);

      expect(await ChapterCache.has('post_clear.txt'), isTrue);
      expect(await ChapterCache.read('post_clear.txt'), 'ABC');
    });
  });

  group('ChapterCache TTL', () {
    test('read returns null for stale entries older than 7 days', () async {
      await ChapterCache.save('stale.txt', [65, 66, 67]);

      final cacheDir = Directory('${tempDir.path}/chapters_cache');
      final staleFile = File('${cacheDir.path}/stale.txt');
      // Set modification time to 8 days ago
      await staleFile.setLastModified(
        DateTime.now().subtract(const Duration(days: 8)),
      );

      final result = await ChapterCache.read('stale.txt');
      expect(result, isNull);
    });

    test('read returns content for fresh entries', () async {
      await ChapterCache.save('fresh.txt', [72, 73, 74]);

      final result = await ChapterCache.read('fresh.txt');
      expect(result, 'HIJ');
    });
  });
}
