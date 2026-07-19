import 'dart:io';
import 'package:flutter/material.dart';

class AvatarSection extends StatelessWidget {
  final String? pendingAvatarPath;
  final String? avatarUrl;
  final bool isSaving;
  final VoidCallback onPickImage;

  const AvatarSection({
    super.key,
    required this.pendingAvatarPath,
    required this.avatarUrl,
    required this.isSaving,
    required this.onPickImage,
  });

  ImageProvider<Object>? _avatarImage() {
    if (pendingAvatarPath != null) return FileImage(File(pendingAvatarPath!));
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
            child: (pendingAvatarPath == null && avatarUrl == null)
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
