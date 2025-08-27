import 'package:flutter/material.dart';

/// Widget displayed when the car list is empty
class EmptyStateWidget extends StatelessWidget {
  final bool hasActiveFilters;

  const EmptyStateWidget({
    super.key,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters
                ? 'Aucune voiture ne correspond aux filtres'
                : 'Aucune voiture dans la collection',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (!hasActiveFilters) ...[
            const SizedBox(height: 16),
            Text(
              'Appuyez sur + pour ajouter votre première voiture',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}