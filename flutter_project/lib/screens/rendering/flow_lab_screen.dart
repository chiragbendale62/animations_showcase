import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlowLabScreen extends StatefulWidget {
  const FlowLabScreen({super.key});

  @override
  State<FlowLabScreen> createState() => _FlowLabScreenState();
}

class _FlowLabScreenState extends State<FlowLabScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int stackBuildCount = 0;
  int flowBuildCount = 0;

  bool animate = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildInfoCard(
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

  Widget buildOrb(Color color) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    stackBuildCount++;

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        title: const Text(
          "Flow Widget Lab",
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "STACK vs FLOW",
            style: TextStyle(
              color: Colors.cyanAccent,
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
                  child: buildInfoCard(
                    "Stack Builds",
                    "$stackBuildCount",
                    Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildInfoCard(
                    "Flow Builds",
                    "$flowBuildCount",
                    Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: buildStackDemo(),
                ),
                Expanded(
                  child: buildFlowDemo(),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black54,
            child: Row(
              children: [
                const Text(
                  "Animation",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: animate,
                  onChanged: (v) {
                    setState(() {
                      animate = v;

                      if (animate) {
                        _controller.repeat();
                      } else {
                        _controller.stop();
                      }
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

  Widget buildStackDemo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.redAccent,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 100 +
                    math.sin(
                      _controller.value * math.pi * 2,
                    ) *
                        60,
                top: 100,
                child: buildOrb(
                  Colors.redAccent,
                ),
              ),
              Positioned(
                left: 120,
                top: 220 +
                    math.cos(
                      _controller.value * math.pi * 2,
                    ) *
                        60,
                child: buildOrb(
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFlowDemo() {
    flowBuildCount++;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.greenAccent,
        ),
      ),
      child: Flow(
        delegate: OrbitFlowDelegate(
          animation: _controller,
        ),
        children: [
          buildOrb(Colors.greenAccent),
          buildOrb(Colors.cyanAccent),
          buildOrb(Colors.blueAccent),
        ],
      )
    );
  }
}

class OrbitFlowDelegate extends FlowDelegate {
  final Animation<double> animation;

  OrbitFlowDelegate({
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paintChildren(
      FlowPaintingContext context,
      ) {
    final centerX = context.size.width / 2;
    final centerY = context.size.height / 2;

    for (int i = 0; i < context.childCount; i++) {
      final angle =
          animation.value * math.pi * 2 + i;

      final x =
          centerX + math.cos(angle) * 100;

      final y =
          centerY + math.sin(angle) * 100;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          x,
          y,
          0,
        ),
      );
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }

  @override
  bool shouldRepaint(
      covariant OrbitFlowDelegate oldDelegate,
      ) {
    return false;
  }
}