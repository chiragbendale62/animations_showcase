import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/aurora_painter.dart';

class ShaderLabScreen extends StatefulWidget {
  const ShaderLabScreen({super.key});

  @override
  State<ShaderLabScreen> createState() => _ShaderLabScreenState();
}

class _ShaderLabScreenState extends State<ShaderLabScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  FragmentShader? shader;

  double speed = 1.0;
  double intensity = 1.0;

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    loadShader();
  }

  @override
  Widget build(BuildContext context) {

    if (!loaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "GPU Fragment Shader Lab",
        ),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            children: [

              Expanded(
                child: CustomPaint(
                  painter: AuroraPainter(
                    shader!,
                    controller.value,
                    speed,
                    intensity,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              buildControls(),
            ],
          );
        },
      ),
    );
  }

  Future<void> loadShader() async {
    final program = await FragmentProgram.fromAsset('shaders/aurora.frag');

    shader = program.fragmentShader();

    setState(() {
      loaded = true;
    });
  }

  Widget buildControls() {

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: Column(
        children: [

          const Text(
            "Speed",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          Slider(
            value: speed,
            min: 0.2,
            max: 5,
            onChanged: (v) {
              setState(() {
                speed = v;
              });
            },
          ),

          const Text(
            "Intensity",
            style: TextStyle(
              color: Colors.white,
            ),
          ),

          Slider(
            value: intensity,
            min: 0.2,
            max: 3,
            onChanged: (v) {
              setState(() {
                intensity = v;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}


// Animated Aurora Background
// Blue → Purple GPU glow
// Adjustable speed
// Adjustable intensity
// Smooth 60/120 FPS rendering
// Modern rendering-engine demonstration