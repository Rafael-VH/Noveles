import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/shared/presentation/widgets/snackbar_helper.dart';

void main() {
  group('SnackbarHelper', () {
    testWidgets('successSnack shows green background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showSuccessSnack(context, 'Saved!'),
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.content, isA<Text>());
      expect((snackBar.content as Text).data, 'Saved!');
      expect(snackBar.backgroundColor, isNotNull);
    });

    testWidgets('errorSnack shows error background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showErrorSnack(context, 'Failed!'),
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect((snackBar.content as Text).data, 'Failed!');
      expect(snackBar.backgroundColor, isNotNull);
    });

    testWidgets('successSnack uses green, errorSnack uses theme error color', (tester) async {
      Color? successColor;
      Color? errorColor;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showSuccessSnack(context, 'OK');
                    },
                    child: const Text('Success'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showErrorSnack(context, 'ERR');
                    },
                    child: const Text('Error'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Success'));
      await tester.pumpAndSettle();
      successColor = tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor;
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Error'));
      await tester.pumpAndSettle();
      errorColor = tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor;

      expect(successColor, equals(Colors.green.shade700));
      expect(errorColor, isNot(equals(Colors.green.shade700)));
    });
  });
}
