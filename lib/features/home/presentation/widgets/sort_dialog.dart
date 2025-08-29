import 'package:flutter/material.dart';
import '../../../../app/constants/strings.dart';
import '../../../../domain/entities/filter.dart';

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

  String getSortSubtitle(SortOption option, bool ascending) {
    switch (option) {
      case SortOption.name:
      case SortOption.brand:
      case SortOption.shape:
        return ascending ? 'A → Z' : 'Z → A';
      case SortOption.createdAt:
      case SortOption.updatedAt:
        return ascending ? 'Ancien → Récent' : 'Récent → Ancien';
    }
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
            subtitle: Text(getSortSubtitle(_selectedSortBy, _ascending)),
            value: _ascending,
            onChanged: (value) {
              setState(() => _ascending = value);
            },
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, (
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