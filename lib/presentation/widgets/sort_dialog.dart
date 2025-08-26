import 'package:flutter/material.dart';
import '../../data/models/filter_model.dart';

class SortDialog extends StatefulWidget {
  final SortOption currentSortBy;
  final bool currentAscending;

  const SortDialog({
    super.key,
    required this.currentSortBy,
    required this.currentAscending,
  });

  @override
  State<SortDialog> createState() => _SortDialogState();
}

class _SortDialogState extends State<SortDialog> {
  late SortOption _selectedSortBy;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy;
    _ascending = widget.currentAscending;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Trier par'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...SortOption.values.map((option) => RadioListTile<SortOption>(
            title: Text(option.displayName),
            value: option,
            groupValue: _selectedSortBy,
            onChanged: (value) {
              setState(() => _selectedSortBy = value!);
            },
          )),
          const Divider(),
          SwitchListTile(
            title: const Text('Ordre croissant'),
            subtitle: Text(_ascending ? 'A → Z' : 'Z → A'),
            value: _ascending,
            onChanged: (value) {
              setState(() => _ascending = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop((
            sortBy: _selectedSortBy,
            ascending: _ascending,
            ));
          },
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}