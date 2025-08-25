import 'package:flutter/material.dart';
import '../models/car.dart';

class CarListItem extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CarListItem({
    Key? key,
    required this.car,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  Widget _buildImage() {
    if (car.photo != null && car.photo!.isNotEmpty) {
      return Image.memory(
        car.photo!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.directions_car, size: 36, color: Colors.grey[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildImage()),
      title: Text(car.name),
      subtitle: Text('${car.brand} • ${car.shape}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (car.isPiggyBank)
            Tooltip(message: 'Tirelire', child: Icon(Icons.savings)),
          SizedBox(width: 6),
          if (car.playsMusic) Tooltip(message: 'Fait de la musique', child: Icon(Icons.music_note)),
          if (onDelete != null) ...[
            SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Supprimer',
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
