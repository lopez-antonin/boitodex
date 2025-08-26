import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class ImageCropDialog extends StatefulWidget {
  final Uint8List imageBytes;

  const ImageCropDialog({
    super.key,
    required this.imageBytes,
  });

  @override
  State<ImageCropDialog> createState() => _ImageCropDialogState();
}

class _ImageCropDialogState extends State<ImageCropDialog> {
  final GlobalKey _cropKey = GlobalKey();
  late ui.Image _image;
  bool _isImageLoaded = false;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Size _imageSize = Size.zero;
  Size _containerSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final codec = await ui.instantiateImageCodec(widget.imageBytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _imageSize = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      _isImageLoaded = true;
    });
  }

  Future<Uint8List> _cropImage() async {
    if (!_isImageLoaded) throw Exception('Image non chargée');

    final RenderRepaintBoundary boundary =
    _cropKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) throw Exception('Erreur lors du recadrage');

    return byteData.buffer.asUint8List();
  }

  void _updateTransform(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_scale * details.scale).clamp(0.5, 3.0);
      _offset += details.focalPointDelta;

      // Contraindre l'offset pour garder l'image dans les limites
      final double maxOffsetX = (_containerSize.width - _imageSize.width * _scale) / 2;
      final double maxOffsetY = (_containerSize.height - _imageSize.height * _scale) / 2;

      _offset = Offset(
        _offset.dx.clamp(-math.max(0, _imageSize.width * _scale - _containerSize.width) / 2, math.max(0, _imageSize.width * _scale - _containerSize.width) / 2),
        _offset.dy.clamp(-math.max(0, _imageSize.height * _scale - _containerSize.height) / 2, math.max(0, _imageSize.height * _scale - _containerSize.height) / 2),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Recadrer l\'image',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajustez l\'image pour qu\'elle soit au format carré',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: !_isImageLoaded
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                builder: (context, constraints) {
                  _containerSize = Size(constraints.maxWidth, constraints.maxHeight);
                  final cropSize = math.min(constraints.maxWidth, constraints.maxHeight) - 32;

                  return Center(
                    child: Stack(
                      children: [
                        // Image avec transformation
                        RepaintBoundary(
                          key: _cropKey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: cropSize,
                              height: cropSize,
                              color: Colors.grey[200],
                              child: GestureDetector(
                                onScaleUpdate: _updateTransform,
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(_scale)
                                    ..translate(_offset.dx, _offset.dy),
                                  child: Image.memory(
                                    widget.imageBytes,
                                    fit: BoxFit.cover,
                                    width: cropSize,
                                    height: cropSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Guide de recadrage
                        Positioned.fill(
                          child: Container(
                            width: cropSize,
                            height: cropSize,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pincez pour zoomer, faites glisser pour ajuster',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final croppedImage = await _cropImage();
                      if (mounted) {
                        Navigator.of(context).pop(croppedImage);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Recadrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}