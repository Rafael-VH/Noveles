import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the backend seam.
///
/// Feature code talks to the backend exclusively through the ports in
/// `lib/core/backend`. Without these assertions the next feature — or the next
/// test — can import the SDK directly and silently undo the portability work,
/// which is how the coupling accumulated in the first place. They describe the
/// invariant, not a snapshot of current style, so they hold for any backend.
void main() {
  /// The one directory allowed to name a vendor. Everything else in the app,
  /// features and tests alike, must go through the ports.
  const adapterRoot = 'lib/core/backend/';

  /// The vendor's package name, as it appears in an import URI.
  final vendorImport =
      RegExp(r'''^\s*import\s+['"][^'"]*supabase''');

  List<File> dartFilesIn(String directory) => Directory(directory)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  /// Separator-neutral, so the prefix check behaves the same on Windows.
  String normalized(String path) => path.replaceAll(r'\', '/');

  final adapterFiles = dartFilesIn('lib/core/backend');
  final restOfLib = dartFilesIn('lib')
      .where((file) => !normalized(file.path).startsWith(adapterRoot))
      .toList();
  final repositoryTestFiles = dartFilesIn('test/repositories');

  /// Every line of every file that matches [pattern], prefixed with the file it
  /// came from — so a failure names the offender, not just a count.
  List<String> matches(Iterable<File> files, RegExp pattern) {
    final found = <String>[];
    for (final file in files) {
      for (final line in file.readAsLinesSync()) {
        if (pattern.hasMatch(line)) {
          found.add('${file.path} → ${line.trim()}');
        }
      }
    }
    return found;
  }

  test('the scan sees real files, so a silent green is impossible', () {
    expect(adapterFiles, isNotEmpty);
    expect(restOfLib, isNotEmpty);
    expect(repositoryTestFiles, isNotEmpty);
  });

  test('only the adapter imports the backend SDK', () {
    final offenders = matches(restOfLib, vendorImport);
    expect(
      offenders,
      isEmpty,
      reason: 'Use the DataGateway/AuthGateway/StorageGateway ports instead:\n'
          '${offenders.join('\n')}',
    );
  });

  test('backend types do not leak outside the adapter', () {
    // Reaching the SDK through inference still couples the caller to it.
    final offenders =
        matches(restOfLib, RegExp(r'\bSupabase(Client|\.instance)\b'));
    expect(
      offenders,
      isEmpty,
      reason: 'Vendor types must not appear outside $adapterRoot:\n'
          '${offenders.join('\n')}',
    );
  });

  test('aggregate reads stay inside the adapter', () {
    // The embed syntax the adapter uses ('*, authors(*)') is the least portable
    // thing in the old repositories; a '(*' outside it can only mean embedded
    // resources leaking back out.
    final offenders = matches(restOfLib, RegExp(r'\(\*'));
    expect(
      offenders,
      isEmpty,
      reason: 'Embedded-resource reads belong to the gateway implementation:\n'
          '${offenders.join('\n')}',
    );
  });

  test('repository tests talk to the ports, not to the SDK', () {
    // The regression this prevents: a new repository test that mocks the SDK's
    // query builders instead of the ports, which is exactly the debt the
    // migration paid off.
    final offenders = matches(repositoryTestFiles, vendorImport);
    expect(
      offenders,
      isEmpty,
      reason: 'Double the ports with test/utils/backend_mocks.dart:\n'
          '${offenders.join('\n')}',
    );
  });
}
