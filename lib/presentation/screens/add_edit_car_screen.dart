import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_snackbar.dart';
import '../../data/models/car_model.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/image_utils.dart';

class AddEditCarScreen extends ConsumerStatefulWidget {
  final CarModel? existingCar;

  const AddEditCarScreen({super.key, this.existingCar});

  @override
  ConsumerState<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends ConsumerState<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _shapeController = TextEditingController();
  final _nameController = TextEditingController();
  final _informationsController = TextEditingController();

  bool _isPiggyBank = false;
  bool _playsMusic = false;
  Uint8List? _photoBytes;
  bool _isLoading = false;

  bool get _isEditing => widget.existingCar != null;

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

  void _populateFields() {
    final car = widget.existingCar!;
    _brandController.text = car.brand;
    _shapeController.text = car.shape;
    _nameController.text = car.name;
    _informationsController.text = car.informations ?? '';
    _isPiggyBank = car.isPiggyBank;
    _playsMusic = car.playsMusic;
    _photoBytes = car.photo;
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  Future<void> _onImageSelected(Uint8List imageBytes) async {
    setState(() => _photoBytes = imageBytes);
  }

  void _onImageRemoved() {
    setState(() => _photoBytes = null);
  }

  void _showFullImage() {
    if (_photoBytes == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(_photoBytes!),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);

    try {
      final car = CarModel(
        id: _isEditing ? widget.existingCar!.id : null,
        uuid: _isEditing ? widget.existingCar!.uuid : null,
        brand: _brandController.text.trim(),
        shape: _shapeController.text.trim(),
        name: _nameController.text.trim(),
        informations: _informationsController.text.trim().isEmpty
            ? null
            : _informationsController.text.trim(),
        isPiggyBank: _isPiggyBank,
        playsMusic: _playsMusic,
        photo: _photoBytes,
        createdAt: _isEditing ? widget.existingCar!.createdAt : null,
      );

      if (_isEditing) {
        await ref.read(carNotifierProvider.notifier).updateCar(car);
      } else {
        await ref.read(carNotifierProvider.notifier).addCar(car);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Voiture mise à jour' : 'Voiture ajoutée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(context, 'Erreur lors de la sauvegarde: ${e.toString()}');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _confirmDelete() async {
    if (!_isEditing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la voiture'),
        content: Text('Voulez-vous vraiment supprimer "${widget.existingCar!.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _setLoading(true);
      try {
        await ref.read(carNotifierProvider.notifier).deleteCar(widget.existingCar!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voiture supprimée'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ErrorSnackbar.show(context, 'Erreur lors de la suppression: ${e.toString()}');
        }
      } finally {
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Modifier la voiture' : 'Ajouter une voiture'),
          elevation: 2,
          actions: [
            if (_isEditing)
              IconButton(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Supprimer',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo avec possibilité d'affichage plein écran
                Stack(
                  children: [
                    ImagePickerWidget(
                      imageBytes: _photoBytes,
                      onImageSelected: _onImageSelected,
                      onImageRemoved: _onImageRemoved,
                      imageSize: _photoBytes != null
                          ? ImageUtils.getImageSizeText(_photoBytes)
                          : null,
                    ),
                    if (_photoBytes != null)
                      Positioned(
                        top: 40,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: _showFullImage,
                            icon: const Icon(Icons.fullscreen, color: Colors.white),
                            tooltip: 'Voir en grand',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Marque
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Marque *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.branding_watermark),
                  ),
                  validator: Validators.validateBrand,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Forme
                TextFormField(
                  controller: _shapeController,
                  decoration: const InputDecoration(
                    labelText: 'Forme *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: Validators.validateShape,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Nom
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: Validators.validateName,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Informations
                TextFormField(
                  controller: _informationsController,
                  decoration: const InputDecoration(
                    labelText: 'Informations',
                    hintText: 'Ex: Obtenue pour mon anniversaire, légèrement rayée...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Options (Tirelire et Musique)
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Tirelire'),
                        subtitle: const Text('Cette voiture est une tirelire'),
                        secondary: const Icon(Icons.savings),
                        value: _isPiggyBank,
                        onChanged: (value) => setState(() => _isPiggyBank = value),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Fait de la musique'),
                        subtitle: const Text('Cette voiture émet des sons'),
                        secondary: const Icon(Icons.music_note),
                        value: _playsMusic,
                        onChanged: (value) => setState(() => _playsMusic = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Espace pour les boutons fixes
              ],
            ),
          ),
        ),
        // Boutons fixes en bas
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}