import 'dart:io';
import 'package:flutter/material.dart';

class AvatarSection extends StatelessWidget {
  final File? pendingAvatar;
  final String? avatarUrl;
  final bool isSaving;
  final VoidCallback onPickImage;

  const AvatarSection({
    super.key,
    required this.pendingAvatar,
    required this.avatarUrl,
    required this.isSaving,
    required this.onPickImage,
  });

  ImageProvider<Object>? _avatarImage() {
    if (pendingAvatar != null) return FileImage(pendingAvatar!);
    if (avatarUrl != null) return NetworkImage(avatarUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: isSaving ? null : onPickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _avatarImage(),
            child: (pendingAvatar == null && avatarUrl == null)
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isSaving ? null : onPickImage,
          child: const Text('Cambiar foto'),
        ),
      ],
    );
  }
}
