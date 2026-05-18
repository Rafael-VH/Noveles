import 'package:flutter/material.dart';
import 'package:noveles/core/supabase/storage_helper.dart';

class CoverPicker extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const CoverPicker({
    super.key,
    required this.controller,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.text.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              coverUrl(controller.text),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                size: 100,
              ),
            ),
          ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.image),
              label: const Text('Seleccionar imagen'),
            ),
            if (controller.text.isNotEmpty)
              TextButton(
                onPressed: onClear,
                child: const Text('Quitar'),
              ),
          ],
        ),
        if (controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              controller.text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
