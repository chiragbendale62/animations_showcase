import 'dart:math' as math;
import 'package:flutter/material.dart';

class SaveLayerLabScreen extends StatefulWidget {
  const SaveLayerLabScreen({super.key});

  @override
  State<SaveLayerLabScreen> createState() =>
      _SaveLayerLabScreenState();
}

class _SaveLayerLabScreenState
    extends State<SaveLayerLabScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool useSaveLayer = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget metricCard(
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
          color: color.withOpacity(.3),
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
          const SizedBox(height: 6),
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
            "SAVELAYER vs CLIPRECT",
            style: TextStyle(
              color: Colors.redAccent,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
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
                  child: metricCard(
                    "Technique",
                    useSaveLayer
                        ? "saveLayer"
                        : "clipRect",
                    useSaveLayer
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: metricCard(
                    "GPU Cost",
                    useSaveLayer
                        ? "HIGH"
                        : "LOW",
                    useSaveLayer
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                return Center(
                  child: CustomPaint(
                    size: const Size(
                      320,
                      320,
                    ),
                    painter:
                    SaveLayerBenchmarkPainter(
                      progress:
                      _controller.value,
                      useSaveLayer:
                      useSaveLayer,
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
                  value: useSaveLayer,
                  activeColor: Colors.redAccent,
                  title: const Text(
                    "Use saveLayer()",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      useSaveLayer = v;
                    });
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  useSaveLayer
                      ? "Rendering using saveLayer() → Offscreen GPU buffer"
                      : "Rendering using clipRect() → Direct GPU draw",
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



class SaveLayerBenchmarkPainter
    extends CustomPainter {
  final double progress;
  final bool useSaveLayer;

  SaveLayerBenchmarkPainter({
    required this.progress,
    required this.useSaveLayer,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center =
    Offset(
      size.width / 2,
      size.height / 2,
    );

    final rect =
    Offset.zero & size;

    if (useSaveLayer) {
      canvas.saveLayer(
        rect,
        Paint(),
      );

      _drawScene(
        canvas,
        center,
      );

      canvas.restore();
    } else {
      canvas.clipRect(rect);

      _drawScene(
        canvas,
        center,
      );
    }
  }

  void _drawScene(
      Canvas canvas,
      Offset center,
      ) {
    for (int i = 0; i < 40; i++) {
      final angle =
          progress *
              math.pi *
              2 +
              i * 0.3;

      final radius =
          40 + i * 3.5;

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
        ..color =
        Colors.blueAccent
            .withOpacity(.2)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          12,
        );

      canvas.drawCircle(
        Offset(x, y),
        20,
        paint,
      );
    }

    final ringPaint =
    Paint()
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader =
      SweepGradient(
        colors: [
          Colors.cyanAccent,
          Colors.blueAccent,
          Colors.purpleAccent,
          Colors.cyanAccent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: 120,
        ),
      );

    canvas.drawCircle(
      center,
      120,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant SaveLayerBenchmarkPainter oldDelegate) {
    return true;
  }
}




// What This Lab Teaches
// saveLayer()
// canvas.saveLayer(...)
//
// Flutter:
//
// Create Offscreen Buffer
//
// Render Everything
//
// Copy Texture Back
//
// Render Again
//
// GPU work increases.
//
// clipRect()
// canvas.clipRect(...)
//
// Flutter:
//
// Clip Region
//
// Render Directly
//
// No Extra Buffer
//
// Much cheaper.
//
// Visual Result
// saveLayer Mode
// Red Badge
//
// GPU Cost: HIGH
//
// Glowing Orbiting Particles
// clipRect Mode
// Green Badge
//
// GPU Cost: LOW
//
// Same Visual Output