import 'package:flutter/material.dart';
import '../core/utils.dart';

/// Widget containing all form fields for car data entry
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
        // Brand field
        TextFormField(
          controller: brandController,
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
          controller: shapeController,
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
          controller: nameController,
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
          controller: informationsController,
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
                value: isPiggyBank,
                onChanged: onPiggyBankChanged,
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Fait de la musique'),
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