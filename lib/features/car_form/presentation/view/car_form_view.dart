import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/constants/strings.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/shared/widgets/loading_widget.dart';
import '../../../../domain/entities/car.dart';
import '../viewmodel/car_form_viewmodel.dart';
import '../widgets/car_form_fields.dart';
import '../widgets/image_section.dart';

class CarFormView extends StatefulWidget {
  final Car? car;

  const CarFormView({super.key, this.car});

  @override
  State<CarFormView> createState() => _CarFormViewState();
}

class _CarFormViewState extends State<CarFormView> {
  final _formKey = GlobalKey<FormState>();
  late final CarFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator<CarFormViewModel>();
    _viewModel.initializeWithCar(widget.car);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_viewModel.isEditing ? AppStrings.edit : AppStrings.add),
          actions: [
            if (_viewModel.isEditing)
              Consumer<CarFormViewModel>(
                builder: (context, viewModel, child) {
                  return IconButton(
                    onPressed: viewModel.isLoading ? null : _deleteCar,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                  );
                },
              ),
          ],
        ),
        body: Consumer<CarFormViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const LoadingWidget();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageSectionWidget(
                      photoBytes: viewModel.photoBytes,
                      onImageTap: _showImageOptions,
                    ),
                    const SizedBox(height: 24),
                    CarFormFields(
                      brandController: viewModel.brandController,
                      shapeController: viewModel.shapeController,
                      nameController: viewModel.nameController,
                      informationsController: viewModel.informationsController,
                      isPiggyBank: viewModel.isPiggyBank,
                      playsMusic: viewModel.playsMusic,
                      onPiggyBankChanged: viewModel.setPiggyBank,
                      onPlaysMusicChanged: viewModel.setPlaysMusic,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Consumer<CarFormViewModel>(
          builder: (context, viewModel, child) {
            return Container(
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
                      onPressed: viewModel.isLoading ? null : _saveCar,
                      child: const Text(AppStrings.save),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Appareil photo'),
              onTap: () {
                Navigator.pop(context);
                _viewModel.pickImageFromCamera();
              },
            ),
            if (_viewModel.photoBytes != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer l\'image'),
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.setPhoto(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.saveCar();
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (_viewModel.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la voiture'),
        content: const Text(AppStrings.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _viewModel.deleteCurrentCar();
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voiture supprimée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}