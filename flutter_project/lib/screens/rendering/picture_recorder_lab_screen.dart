import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class PictureRecorderLabScreen extends StatefulWidget {
  const PictureRecorderLabScreen({super.key});

  @override
  State<PictureRecorderLabScreen> createState() =>
      _PictureRecorderLabScreenState();
}

class _PictureRecorderLabScreenState
    extends State<PictureRecorderLabScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool useCache = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildMetric(
      String title,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "PICTURE RECORDER CACHE LAB",
            style: TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: buildMetric(
                    "Mode",
                    useCache
                        ? "Cached"
                        : "Realtime",
                    useCache
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildMetric(
                    "Vector Objects",
                    "500+",
                    Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Center(
                  child: Transform.rotate(
                    angle:
                    _controller.value *
                        math.pi *
                        2,
                    child: CustomPaint(
                      size: const Size(
                        320,
                        320,
                      ),
                      painter: ComplexVectorPainter(
                        useCache: useCache,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black54,
            child: Column(
              children: [
                SwitchListTile(
                  value: useCache,
                  activeColor: Colors.greenAccent,
                  title: const Text(
                    "Enable Picture Cache",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      useCache = v;
                    });
                  },
                ),

                const SizedBox(height: 12),

                Text(
                  useCache
                      ? "Picture recorded once and replayed every frame."
                      : "Paths recreated every frame.",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class ComplexVectorPainter
    extends CustomPainter {
  final bool useCache;

  ComplexVectorPainter({
    required this.useCache,
  });

  static Picture? cachedPicture;

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    if (useCache) {
      _paintCached(
        canvas,
        size,
      );
    } else {
      _paintRealtime(
        canvas,
        size,
      );
    }
  }

  void _paintCached(
      Canvas canvas,
      Size size,
      ) {
    cachedPicture ??=
        _generatePicture(size);

    canvas.drawPicture(
      cachedPicture!,
    );
  }

  void _paintRealtime(
      Canvas canvas,
      Size size,
      ) {
    _drawComplexScene(
      canvas,
      size,
    );
  }

  Picture _generatePicture(
      Size size,
      ) {
    final recorder =
    PictureRecorder();

    final recordingCanvas =
    Canvas(recorder);

    _drawComplexScene(
      recordingCanvas,
      size,
    );

    return recorder.endRecording();
  }

  void _drawComplexScene(
      Canvas canvas,
      Size size,
      ) {
    final center =
    Offset(
      size.width / 2,
      size.height / 2,
    );

    for (int i = 0; i < 500; i++) {
      final radius =
          (i % 50) * 3.0;

      final angle =
          i * 0.2;

      final x =
          center.dx +
              math.cos(angle) *
                  radius;

      final y =
          center.dy +
              math.sin(angle) *
                  radius;

      final paint =
      Paint()
        ..style =
            PaintingStyle.stroke
        ..strokeWidth =
        1.5
        ..shader =
        RadialGradient(
          colors: [
            Colors.cyanAccent,
            Colors.blueAccent,
            Colors.purpleAccent,
          ],
        ).createShader(
          Rect.fromCircle(
            center:
            Offset(x, y),
            radius: 25,
          ),
        );

      canvas.drawCircle(
        Offset(x, y),
        radius * .2,
        paint,
      );
    }

    final starPaint =
    Paint()
      ..color =
          Colors.amberAccent
      ..strokeWidth = 2
      ..style =
          PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < 12; i++) {
      final angle =
          i *
              (math.pi /
                  6);

      final r =
      i.isEven
          ? 120.0
          : 60.0;

      final x =
          center.dx +
              math.cos(angle) *
                  r;

      final y =
          center.dy +
              math.sin(angle) *
                  r;

      if (i == 0) {
        path.moveTo(
          x,
          y,
        );
      } else {
        path.lineTo(
          x,
          y,
        );
      }
    }

    path.close();

    canvas.drawPath(
      path,
      starPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant ComplexVectorPainter oldDelegate) {
    return oldDelegate.useCache !=
        useCache;
  }
}




// What This Demonstrates
// Realtime Mode
// _drawComplexScene(...)
//
// Runs:
//
// 500 circles
// 500 gradients
// Star path
//
// Every frame
// Cached Mode
// PictureRecorder
//
// Creates:
//
// Picture
//
// once.
//
// Then:
//
// canvas.drawPicture(...)
//
// every frame.
//
// Interview Explanation
//
// If interviewer asks:
//
// Why use PictureRecorder?
//
// Answer:
//
// Complex vector drawings can be expensive.
//
// Instead of recreating paths, gradients,
// and geometry every frame inside CustomPainter,
// I can record the drawing once using PictureRecorder.
//
// Flutter stores it as a Picture.
//
// Future frames simply replay that Picture
// using drawPicture(), reducing CPU paint work
// and improving FPS.
// Expected Result
//
// You will see:
//
// Realtime Mode
// Paint Cost High
//
// Complex shape recreated continuously.
//
// Cached Mode
// Paint Cost Low
//
// Same visual output.
//
// Much lower rendering cost.