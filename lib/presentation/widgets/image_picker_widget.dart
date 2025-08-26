import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'error_snackbar.dart';
import '../../core/constants/app_constants.dart';

class ImagePickerWidget extends ConsumerStatefulWidget {
  final Uint8List? imageBytes;
  final ValueChanged<Uint8List> onImageSelected;
  final VoidCallback onImageRemoved;
  final String? imageSize;

  const ImagePickerWidget({
    super.key,
    this.imageBytes,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.imageSize,
  });

  @override
  ConsumerState<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  bool _isLoading = false;

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);

    final imageService = ref.read(imageServiceProvider);
    final result = await imageService.pickFromGallery();

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      widget.onImageSelected(result.data!);
    } else {
      if (mounted) {
        ErrorSnackbar.show(context, result.error!);
      }
    }
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoading = true);

    final imageService = ref.read(imageServiceProvider);
    final result = await imageService.takePhoto();

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      widget.onImageSelected(result.data!);
    } else {
      if (mounted) {
        ErrorSnackbar.show(context, result.error!);
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir dans la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (widget.imageBytes != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer l\'image'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onImageRemoved();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxHeight: 400, // Hauteur maximale pour éviter que l'image prenne trop de place
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Stack(
            children: [
              // Image affichée en entier avec fit.contain
              Center(
                child: Image.memory(
                  widget.imageBytes!,
                  fit: BoxFit.contain, // Affiche l'image entière
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: widget.onImageRemoved,
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Supprimer l\'image',
                  ),
                ),
              ),
              if (widget.imageSize != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.imageSize!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Colors.grey[300]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune image sélectionnée',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez pour ajouter une photo',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : _showImageOptions,
          child: _buildImagePreview(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galerie'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Caméra'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}