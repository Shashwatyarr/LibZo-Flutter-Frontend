import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/post_service.dart';

class TelegramImage extends StatefulWidget {
  final String fileId;
  final double? height;
  final double? width;
  final BoxFit fit;

  const TelegramImage({
    super.key,
    required this.fileId,
    this.height,
    this.width,
    this.fit = BoxFit.fitWidth,
  });

  @override
  State<TelegramImage> createState() => _TelegramImageState();
}

class _TelegramImageState extends State<TelegramImage> {
  Future<Uint8List>? _future;

  @override
  void initState() {
    super.initState();
    _future = loadImage();
  }

  Future<Uint8List> loadImage() async {
    final token = await ApiService.getToken();

    final res = await http.get(
      Uri.parse("${ApiService.baseUrl}/media/${widget.fileId}"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return res.bodyBytes;
    } else {
      throw Exception("Failed to load image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {

        // 1️⃣ LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: widget.height ,
            width: widget.width ,
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2️⃣ ERROR
        if (snapshot.hasError) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _future = loadImage();
              });
            },
            child: Container(
              height: widget.height ?? 200,
              width: widget.width ?? double.infinity,
              color: Colors.grey[900],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  SizedBox(height: 6),
                  Text(
                    "Tap to retry",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          );
        }

        // 3️⃣ SUCCESS
        return Image.memory(
          snapshot.data!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
        );
      },
    );
  }
}
