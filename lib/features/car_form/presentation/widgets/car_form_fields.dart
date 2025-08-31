import 'package:flutter/material.dart';
import '../../../../app/constants/strings.dart';
import '../../../../core/utils/validation_utils.dart';

class CarFormFields extends StatelessWidget {
  final TextEditingController brandController;
  final TextEditingController shapeController;
  final TextEditingController nameController;
  final TextEditingController informationsController;
  final bool isPiggyBank;
  final bool playsMusic;
  final Function(bool) onPiggyBankChanged;
  final Function(bool) onPlaysMusicChanged;

  const CarFormFields({
    super.key,
    required this.brandController,
    required this.shapeController,
    required this.nameController,
    required this.informationsController,
    required this.isPiggyBank,
    required this.playsMusic,
    required this.onPiggyBankChanged,
    required this.onPlaysMusicChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          key: const Key('brand_field'),
          controller: brandController,
          decoration: const InputDecoration(
            labelText: '${AppStrings.brand} *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => ValidationUtils.validateRequired(value, AppStrings.brand),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('shape_field'),
          controller: shapeController,
          decoration: const InputDecoration(
            labelText: '${AppStrings.shape} *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => ValidationUtils.validateRequired(value, AppStrings.shape),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('name_field'),
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '${AppStrings.name} *',
            border: OutlineInputBorder(),
          ),
          validator: (value) => ValidationUtils.validateRequired(value, AppStrings.name),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('informations_field'),
          controller: informationsController,
          decoration: const InputDecoration(
            labelText: AppStrings.informations,
            hintText: 'Notes, état, origine...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) => ValidationUtils.validateMaxLength(value, 500, AppStrings.informations),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(AppStrings.isPiggyBank),
                subtitle: const Text('Cette voiture est une tirelire'),
                value: isPiggyBank,
                onChanged: onPiggyBankChanged,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(AppStrings.playsMusic),
                subtitle: const Text('Cette voiture émet des sons'),
                value: playsMusic,
                onChanged: onPlaysMusicChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}