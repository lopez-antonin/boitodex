import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/car_service.dart';
import '../services/image_service.dart';
import '../models/car.dart';
import '../core/utils.dart';

/// Screen for adding or editing a car
class CarFormScreen extends StatefulWidget {
  final Car? car; // null for add, non-null for edit

  const CarFormScreen({super.key, this.car});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final CarService _carService = CarService();
  final ImageService _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _brandController = TextEditingController();
  final _shapeController = TextEditingController();
  final _nameController = TextEditingController();
  final _informationsController = TextEditingController();

  // Form state
  bool _isPiggyBank = false;
  bool _playsMusic = false;
  Uint8List? _photoBytes;
  bool _isLoading = false;

  bool get _isEditing => widget.car != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _shapeController.dispose();
    _nameController.dispose();
    _informationsController.dispose();
    super.dispose();
  }

  /// Populate form fields when editing
  void _populateFields() {
    final car = widget.car!;
    _brandController.text = car.brand;
    _shapeController.text = car.shape;
    _nameController.text = car.name;
    _informationsController.text = car.informations ?? '';
    _isPiggyBank = car.isPiggyBank;
    _playsMusic = car.playsMusic;
    _photoBytes = car.photo;
  }

  /// Save the car (add or update)
  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final car = Car(
      id: _isEditing ? widget.car!.id : null,
      brand: _brandController.text.trim(),
      shape: _shapeController.text.trim(),
      name: _nameController.text.trim(),
      informations: _informationsController.text.trim().isEmpty
          ? null
          : _informationsController.text.trim(),
      isPiggyBank: _isPiggyBank,
      playsMusic: _playsMusic,
      photo: _photoBytes,
      createdAt: _isEditing ? widget.car!.createdAt : null,
    );

    final success = _isEditing
        ? await _carService.updateCar(car)
        : await _carService.addCar(car);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sauvegarde'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Delete the car (only when editing)
  Future<void> _deleteCar() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la voiture'),
        content: Text('Voulez-vous vraiment supprimer "${widget.car!.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _carService.deleteCar(widget.car!.id!);
      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voiture supprimée')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la suppression'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Show image selection options
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_photoBytes != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer l\'image'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoBytes = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Pick image from gallery
  Future<void> _pickFromGallery() async {
    final imageBytes = await _imageService.pickFromGallery();
    if (imageBytes != null) {
      setState(() => _photoBytes = imageBytes);
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    final imageBytes = await _imageService.takePhoto();
    if (imageBytes != null) {
      setState(() => _photoBytes = imageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier' : 'Ajouter'),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _deleteCar,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Brand field
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marque *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Utils.validateRequired(value, 'La marque'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Shape field
              TextFormField(
                controller: _shapeController,
                decoration: const InputDecoration(
                  labelText: 'Forme *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Utils.validateRequired(value, 'La forme'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => Utils.validateRequired(value, 'Le nom'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Informations field
              TextFormField(
                controller: _informationsController,
                decoration: const InputDecoration(
                  labelText: 'Informations',
                  hintText: 'Notes, état, origine...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => Utils.validateMaxLength(value, 500, 'Les informations'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Options section
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Tirelire'),
                      subtitle: const Text('Cette voiture est une tirelire'),
                      value: _isPiggyBank,
                      onChanged: (value) => setState(() => _isPiggyBank = value),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Fait de la musique'),
                      subtitle: const Text('Cette voiture émet des sons'),
                      value: _playsMusic,
                      onChanged: (value) => setState(() => _playsMusic = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for bottom buttons
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCar,
                child: const Text('Enregistrer'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the image selection section
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showImageOptions,
          child: Container(
            width: double.infinity,
            height: _photoBytes != null ? null : 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _photoBytes != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _photoBytes!,
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
        if (_photoBytes != null) ...[
          const SizedBox(height: 8),
          Text(
            Utils.getImageSizeText(_photoBytes),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}