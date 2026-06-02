import 'package:flutter/material.dart';
import 'package:flutter_project/screens/rendering/flow_lab_screen.dart';
import 'package:flutter_project/screens/rendering/impeller_lab_screen.dart';
import 'package:flutter_project/screens/rendering/picture_recorder_lab_screen.dart';
import 'package:flutter_project/screens/rendering/rive_lab_screen.dart';
import 'package:flutter_project/screens/rendering/save_layer_lab_screen.dart';
import 'package:flutter_project/screens/rendering/scroll_throttle_lab_screen.dart';
import 'package:flutter_project/screens/rendering/shader_lab_screen.dart';
import 'package:flutter_project/widgets/optimization_card.dart';

class RenderingOptimizationScreen extends StatelessWidget {
  const RenderingOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        title: const Text(
          'RENDERING OPTIMIZATION LAB',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          OptimizationCard(
            title: "GPU Fragment Shaders",
            icon: Icons.auto_fix_high,
            color: Colors.blueAccent,
            description:
            "Offload highly complex visual calculations directly onto the GPU using FragmentProgram API and GLSL shaders.",
            benefits: const [
              "Aurora effects",
              "Liquid transitions",
              "Neon glow rendering",
              "0% CPU animation cost",
              "120 FPS rendering"
            ],
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShaderLabScreen(),
                ),
              );
            },
          ),

          OptimizationCard(
            title: "Flow Widget",
            icon: Icons.transform,
            color: Colors.greenAccent,
            description:
            "Animate child positions during paint phase without triggering build/layout cycles.",
            benefits: [
              "No widget rebuilds",
              "No layout recalculation",
              "Matrix transformations only",
              "Ideal for menus & particle systems"
            ],
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FlowLabScreen(),
                ),
              );
            },
          ),

          OptimizationCard(
            title: "PictureRecorder Cache",
            icon: Icons.draw,
            color: Colors.orangeAccent,
            description:
            "Record expensive vector drawings once and replay them instantly.",
            benefits: [
              "Huge CustomPainter optimization",
              "Avoid path recalculation",
              "Perfect for SVG-like scenes",
              "Low CPU usage"
            ],
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PictureRecorderLabScreen(),
                ),
              );
            },
          ),

          OptimizationCard(
            title: "Avoid saveLayer()",
            icon: Icons.warning_amber_rounded,
            color: Colors.redAccent,
            description:
            "saveLayer allocates offscreen GPU buffers and can introduce rendering stalls.",
            benefits: [
              "Use clipRect",
              "Use clipPath",
              "Reduce GPU memory",
              "Better rasterization"
            ],
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SaveLayerLabScreen(),
                ),
              );
            },
          ),

          OptimizationCard(
            title: "Scroll Throttling",
            icon: Icons.swipe_vertical,
            color: Colors.purpleAccent,
            description:
            "Avoid setState during scrolling. Use ValueNotifier and Transform widgets.",
            benefits: [
              "Smooth parallax",
              "Reduced rebuilds",
              "Better FPS",
              "Efficient scrolling"
            ],
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScrollThrottleLabScreen(),
                ),
              );
            },
          ),

          // OptimizationCard(
          //   title: "Rive Runtime",
          //   icon: Icons.animation,
          //   color: Colors.pinkAccent,
          //   description:
          //   "Native runtime animation engine with state machines.",
          //   benefits: [
          //     "Smaller than GIF",
          //     "Interactive animations",
          //     "Native interpolation",
          //     "Low CPU load"
          //   ],
          //   onTap: (){
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => const RiveLabScreen(),
          //       ),
          //     );
          //   },
          // ),

          OptimizationCard(
            title: "Impeller Engine",
            icon: Icons.bolt,
            color: Colors.cyanAccent,
            description:
            "Flutter's modern rendering engine with precompiled shaders.",
            benefits: [
              "No shader jank",
              "Stable FPS",
              "Fast startup rendering",
              "Improved Android performance"
            ],
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImpellerLabScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}









// What This Lab Demonstrates
// BAD
// _scrollController.addListener(() {
// setState(() {});
// });
//
// Every scroll tick:
//
// Build
// Layout
// Paint
//
// entire screen.
//
// GOOD
// ValueNotifier<double>
//
// Only:
//
// ValueListenableBuilder
//
// rebuilds.
//
// Visual Result
// BAD MODE
// Background
// List
// Metrics
//
// ALL REBUILD
//
// every scroll.
//
// GOOD MODE
// Background Parallax
//
// ONLY THIS REBUILDS
//
// while list remains untouched.
//
// Interview Answer
//
// If asked:
//
// How do you optimize scroll-driven animations?
//
// Answer:
//
// Avoid calling setState() from every
// ScrollController tick.
//
// Instead, use ValueNotifier,
// AnimatedBuilder, or Transform widgets
// to isolate rebuilds to only the animated
// elements.
//
// This significantly reduces build work
// during high-frequency scrolling and
// helps maintain stable 60/120 FPS.
// Architecture Benefit
//
// This lab pairs perfectly with your:
//
// Explicit Animation Lab
// Physics Lab
// Flow Widget Lab
// PictureRecorder Lab
// saveLayer Lab
//
// because it teaches rebuild isolation, one of the most important Flutter performance optimization techniques.