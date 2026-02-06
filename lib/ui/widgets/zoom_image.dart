import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'telegram_image.dart';

class ZoomableImage extends StatelessWidget {
  final String fileId;

  const ZoomableImage({super.key, required this.fileId});

  @override
  Widget build(BuildContext context) {
    return PhotoView.customChild(
      backgroundDecoration:
      const BoxDecoration(color: Colors.black),

      child: TelegramImage(
        fileId: fileId,
        fit: BoxFit.contain,
      ),
    );
  }
}
