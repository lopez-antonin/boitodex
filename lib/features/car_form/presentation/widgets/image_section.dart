import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_utils.dart';

class ImageSectionWidget extends StatelessWidget {
  final Uint8List? photoBytes;
  final VoidCallback onImageTap;

  const ImageSectionWidget({
    super.key,
    required this.photoBytes,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onImageTap,
          child: Container(
            width: double.infinity,
            height: photoBytes != null ? null : 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: photoBytes != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                photoBytes!,
                fit: BoxFit.contain,
              ),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Ajouter une photo', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        if (photoBytes != null) ...[
          const SizedBox(height: 8),
          Text(
            ImageUtils.getImageSizeText(photoBytes),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}