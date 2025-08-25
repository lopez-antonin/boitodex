import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../providers/car_provider.dart';

class AddEditCarScreen extends StatefulWidget {
  final Car? existingCar;
  const AddEditCarScreen({Key? key, this.existingCar}) : super(key: key);

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _shapeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPiggyBank = false;
  bool _playsMusic = false;
  Uint8List? _photoBytes;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingCar != null) {
      _brandController.text = widget.existingCar!.brand;
      _shapeController.text = widget.existingCar!.shape;
      _nameController.text = widget.existingCar!.name;
      _isPiggyBank = widget.existingCar!.isPiggyBank;
      _playsMusic = widget.existingCar!.playsMusic;
      _photoBytes = widget.existingCar!.photo;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _shapeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _photoBytes = bytes);
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1600, maxHeight: 1600);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _photoBytes = bytes);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CarProvider>();
    final brand = _brandController.text.trim();
    final shape = _shapeController.text.trim();
    final name = _nameController.text.trim();

    if (widget.existingCar == null) {
      await provider.addCar(
        brand: brand,
        shape: shape,
        name: name,
        isPiggyBank: _isPiggyBank,
        playsMusic: _playsMusic,
        photo: _photoBytes,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voiture ajoutée')));
    } else {
      final updated = widget.existingCar!.copyWith(
        brand: brand,
        shape: shape,
        name: name,
        isPiggyBank: _isPiggyBank,
        playsMusic: _playsMusic,
        photo: _photoBytes,
      );
      await provider.updateCar(updated);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voiture mise à jour')));
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    if (widget.existingCar == null) return;
    final provider = context.read<CarProvider>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Supprimer la voiture'),
        content: Text('Voulez-vous vraiment supprimer "${widget.existingCar!.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text('Annuler')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await provider.deleteCar(widget.existingCar!.id!);
      Navigator.of(context).pop(); // close edit screen
    }
  }

  Widget _buildImagePreview() {
    if (_photoBytes != null && _photoBytes!.isNotEmpty) {
      return Image.memory(_photoBytes!, width: double.infinity, height: 200, fit: BoxFit.cover);
    }
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Center(child: Text('Aucune image')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCar != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la voiture' : 'Ajouter une voiture'),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Supprimer',
              icon: Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: Icon(Icons.photo_library),
                      label: Text('Choisir une image'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Prendre une photo'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: 'Marque', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir la marque' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _shapeController,
                decoration: InputDecoration(labelText: 'Forme', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir la forme' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Veuillez saisir le nom' : null,
              ),
              SizedBox(height: 8),
              SwitchListTile(
                title: Text('Tirelire'),
                value: _isPiggyBank,
                onChanged: (v) => setState(() => _isPiggyBank = v),
              ),
              SwitchListTile(
                title: Text('Fait de la musique'),
                value: _playsMusic,
                onChanged: (v) => setState(() => _playsMusic = v),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text('Enregistrer'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Annuler'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
