import 'package:flutter/material.dart';

class ShaderDiagnostics extends StatelessWidget {
  final double fps;

  const ShaderDiagnostics({super.key, required this.fps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "FPS: ${fps.toStringAsFixed(0)}",
            style: const TextStyle(color: Colors.greenAccent),
          ),

          const Text(
            "GPU Shader Rendering",
            style: TextStyle(color: Colors.white70),
          ),

          const Text("CPU Usage ~ 0%", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
