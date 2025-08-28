import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/car_service.dart';
import '../services/image_service.dart';
import '../models/car.dart';
import '../widgets/image_section.dart';
import '../widgets/car_form_fields.dart';
import '../core/dialogs.dart';

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
        Dialogs.showErrorSnackBar(context, 'Erreur lors de la sauvegarde');
      }
    }
  }

  /// Delete the car (only when editing)
  Future<void> _deleteCar() async {
    if (!_isEditing) return;

    final confirm = await Dialogs.showDeleteCarDialog(context, widget.car!.name);

    if (confirm) {
      setState(() => _isLoading = true);
      final success = await _carService.deleteCar(widget.car!.id!);
      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          Dialogs.showSuccessSnackBar(context, 'Voiture supprimée');
        } else {
          Dialogs.showErrorSnackBar(context, 'Erreur lors de la suppression');
        }
      }
    }
  }

  /// Show image selection options
  void _showImageOptions() {
    Dialogs.showImageSelectionBottomSheet(
      context,
      onGalleryTap: _pickFromGallery,
      onCameraTap: _takePhoto,
      onDeleteTap: _photoBytes != null ? () => setState(() => _photoBytes = null) : null,
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
              ImageSectionWidget(
                photoBytes: _photoBytes,
                onImageTap: _showImageOptions,
              ),
              const SizedBox(height: 24),

              // Form fields
              CarFormFields(
                brandController: _brandController,
                shapeController: _shapeController,
                nameController: _nameController,
                informationsController: _informationsController,
                isPiggyBank: _isPiggyBank,
                playsMusic: _playsMusic,
                onPiggyBankChanged: (value) => setState(() => _isPiggyBank = value),
                onPlaysMusicChanged: (value) => setState(() => _playsMusic = value),
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
}