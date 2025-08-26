import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/car_model.dart';
import '../../core/constants/app_constants.dart';

class CarListItem extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CarListItem({
    super.key,
    required this.car,
    required this.onTap,
    this.onDelete,
  });

  Widget _buildImage() {
    if (car.photo != null && car.photo!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Image.memory(
          car.photo!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Icon(
        Icons.directions_car,
        size: 40,
        color: Colors.grey[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildImage(),
        title: Text(
          car.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${car.brand} • ${car.shape}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (car.isPiggyBank) ...[
                  Icon(
                    Icons.savings,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tirelire',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (car.playsMusic) const SizedBox(width: 12),
                ],
                if (car.playsMusic) ...[
                  Icon(
                    Icons.music_note,
                    size: 16,
                    color: Colors.purple[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Musique',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: onDelete != null
            ? IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          tooltip: 'Supprimer',
          color: Colors.red[400],
        )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}