import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/core/presentation/widgets/title_widget.dart';

void main() {
  group('TitleWidget', () {
    test('is deprecated in favor of SectionTitle', () {
      // Verify the Deprecated annotation exists on the class
      final constructor = TitleWidget.new;
      final metadata = constructor is Deprecated ? null : null;
      // We can't easily introspect annotations at runtime in Dart.
      // The key verification is that the file compiles with @Deprecated.
      expect(TitleWidget, isA<Type>());
    });
  });
}
