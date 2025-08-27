import 'package:flutter/material.dart';
import '../models/car.dart';

/// Individual car list item widget
class CarListItem extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CarListItem({
    super.key,
    required this.car,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildCarImage(),
        title: Text(
          car.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${car.brand} • ${car.shape}'),
            if (car.informations?.isNotEmpty ?? false)
              Text(
                car.informations!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (car.isPiggyBank || car.playsMusic) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (car.isPiggyBank) ...[
                    const Icon(Icons.savings, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    const Text('Tirelire', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                  ],
                  if (car.playsMusic) ...[
                    const Icon(Icons.music_note, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    const Text('Musique', style: TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Build car image or placeholder
  Widget _buildCarImage() {
    if (car.photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          car.photo!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  /// Build placeholder when no image
  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.directions_car, color: Colors.grey),
    );
  }
}