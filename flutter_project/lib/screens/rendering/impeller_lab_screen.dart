import 'dart:math' as math;
import 'package:flutter/material.dart';

class ImpellerLabScreen extends StatefulWidget {
  const ImpellerLabScreen({super.key});

  @override
  State<ImpellerLabScreen> createState() =>
      _ImpellerLabScreenState();
}

class _ImpellerLabScreenState
    extends State<ImpellerLabScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double particleCount = 500;

  bool showRepaintBoundaries = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get renderer {
    return "Impeller Ready";
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
      backgroundColor:
      const Color(0xFF050B14),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "IMPELLER ENGINE LAB",
            style: TextStyle(
              color: Colors.cyanAccent,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: metricCard(
                    "Renderer",
                    renderer,
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: metricCard(
                    "Particles",
                    particleCount
                        .toInt()
                        .toString(),
                    Colors.orangeAccent,
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
                return RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter:
                    ParticleStressPainter(
                      progress:
                      _controller.value,
                      count:
                      particleCount
                          .toInt(),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding:
            const EdgeInsets.all(16),
            color: Colors.black54,
            child: Column(
              children: [
                const Text(
                  "Particle Stress Test",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                Slider(
                  value: particleCount,
                  min: 100,
                  max: 3000,
                  divisions: 29,
                  onChanged: (v) {
                    setState(() {
                      particleCount = v;
                    });
                  },
                ),

                Text(
                  "Particles: ${particleCount.toInt()}",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                SwitchListTile(
                  value:
                  showRepaintBoundaries,
                  activeColor:
                  Colors.cyanAccent,
                  title: const Text(
                    "Show Repaint Boundary Info",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (v) {
                    setState(() {
                      showRepaintBoundaries =
                          v;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ParticleStressPainter
    extends CustomPainter {
  final double progress;
  final int count;

  ParticleStressPainter({
    required this.progress,
    required this.count,
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

    for (int i = 0;
    i < count;
    i++) {
      final angle =
          progress *
              math.pi *
              2 +
              i * 0.1;

      final radius =
          (i % 250) * 2.5;

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
        Colors.cyanAccent
            .withOpacity(
          0.4,
        );

      canvas.drawCircle(
        Offset(x, y),
        2,
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
          radius: 140,
        ),
      );

    canvas.drawCircle(
      center,
      140,
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant ParticleStressPainter oldDelegate) {
    return oldDelegate.progress !=
        progress ||
        oldDelegate.count != count;
  }
}