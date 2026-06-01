import 'dart:ui';
import 'package:flutter/material.dart';

class AuroraPainter extends CustomPainter {

  final FragmentShader shader;
  final double time;
  final double speed;
  final double intensity;

  AuroraPainter(
      this.shader,
      this.time,
      this.speed,
      this.intensity,
      );

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {

    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    shader.setFloat(
      2,
      time * 20,
    );

    shader.setFloat(
      3,
      intensity,
    );

    shader.setFloat(
      4,
      speed,
    );

    final paint = Paint()
      ..shader = shader;

    canvas.drawRect(
      Offset.zero & size,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {
    return true;
  }
}