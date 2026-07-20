import 'package:flutter/material.dart';

/// Shows a reusable confirmation dialog.
///
/// Returns `true` if the user confirms, `false` if they cancel,
/// or `null` if the dialog is dismissed via barrier tap.
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: isDestructive
                ? TextStyle(color: Theme.of(context).colorScheme.error)
                : null,
          ),
        ),
      ],
    ),
  );
}
