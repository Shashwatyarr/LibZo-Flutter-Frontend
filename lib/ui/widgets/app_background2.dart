import 'package:flutter/material.dart';

import 'dart:ui';
import 'package:flutter/material.dart';

class AppBackground2 extends StatelessWidget {
  final Widget child;

  const AppBackground2({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🎨 Custom Painted Background
        CustomPaint(
          painter: _LibzoBackground(),
          size: Size.infinite,
        ),

        // 🌫️ Blur Layer
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20, // blur intensity X
            sigmaY: 20, // blur intensity Y
          ),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            // 👆 thoda tint dene ke liye (optional)
          ),
        ),

        // 🧩 Actual UI Content
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: child,
        ),
      ],
    );
  }
}


class _LibzoBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint();

    //Background (Dark Navy/Black)
    paint.shader = const LinearGradient(
      colors: [Color(0xFF020408), Color(0xFF010203)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    //Blue Glow
    paint.shader = RadialGradient(
      colors: [const Color(0xFF0055FF).withOpacity(0.4), Colors.transparent],
      radius: 1.9,
      center: const Alignment(-1.2, -0.6),
    ).createShader(rect);
    canvas.drawRect(rect, paint);


    canvas.save(); //Current state save

    canvas.scale(2.0, 1.0);//x axis 2x stretched hai
    final purpleRect = Rect.fromLTWH(0, 0, size.width, size.height);

    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF7A10E0).withOpacity(0.1),
        Colors.transparent,
      ],
      radius: 0.6,
      center: const Alignment(-0.5, 0.1),
    ).createShader(purpleRect);
    canvas.drawRect(purpleRect, paint);

    canvas.restore(); //restore to normal
    //green orb
    paint.shader = RadialGradient(
      colors: [const Color(0xFF00CC96).withOpacity(0.3), Colors.transparent],
      radius: 1.9,
      center: const Alignment(1.2, 0.6),
    ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}