import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noveles/shared/presentation/widgets/confirmation_dialog.dart';

void main() {
  group('ConfirmationDialog', () {
    testWidgets('displays title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showConfirmationDialog(
                  context: context,
                  title: 'Delete Item',
                  message: 'Are you sure you want to delete this item?',
                  confirmLabel: 'Delete',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Item'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this item?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('returns true when confirm is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showConfirmationDialog(
                    context: context,
                    title: 'Confirm',
                    message: 'Proceed?',
                    confirmLabel: 'Yes',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when cancel is tapped', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showConfirmationDialog(
                    context: context,
                    title: 'Confirm',
                    message: 'Proceed?',
                    confirmLabel: 'Yes',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('shows destructive styling when isDestructive is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showConfirmationDialog(
                  context: context,
                  title: 'Confirm Delete',
                  message: 'This cannot be undone',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('returns null when dialog is dismissed by barrier', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showConfirmationDialog(
                    context: context,
                    title: 'Confirm',
                    message: 'Proceed?',
                    confirmLabel: 'Yes',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap outside dialog (barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
