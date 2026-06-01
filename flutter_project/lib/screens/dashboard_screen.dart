import 'package:flutter/material.dart';
import 'package:flutter_project/screens/rendering/rendering_optimization_screen.dart';
import '../utils/responsive.dart';
import '../widgets/fps_counter.dart';
import 'implicit_playground.dart';
import 'explicit_controller.dart';
import 'isolate_lab_screen.dart';
import 'physics_lab_screen.dart';
import 'hero_showcase_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _LabEntry {
  const _LabEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback Function(BuildContext context) onTap;
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final List<Animation<double>> _staggeredAnimations;

  static final List<_LabEntry> _labs = [
    _LabEntry(
      title: 'Implicit Sandbox',
      subtitle: 'Experiment with Curves, Container frames, and automated state interpolation.',
      icon: Icons.auto_awesome,
      color: Colors.blueAccent,
      onTap: (context) => () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ImplicitPlayground()),
          ),
    ),
    _LabEntry(
      title: 'Explicit Controller',
      subtitle: 'Custom tickers, staggered tweens, and no-rebuild static subtree caching.',
      icon: Icons.settings_suggest,
      color: Colors.purpleAccent,
      onTap: (context) => () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExplicitControllerScreen()),
          ),
    ),
    _LabEntry(
      title: 'Physics & Gesture Lab',
      subtitle: 'Snapping springs, friction fling canvas, and scroll physics.',
      icon: Icons.waves,
      color: Colors.greenAccent,
      onTap: (context) => () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PhysicsLabScreen()),
          ),
    ),
    _LabEntry(
      title: 'Hero Transitions',
      subtitle: 'Shared element transitions with staggered entrance detail loads.',
      icon: Icons.filter_hdr,
      color: Colors.pinkAccent,
      onTap: (context) => () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HeroShowcaseScreen()),
          ),
    ),
    _LabEntry(
      title: 'Isolate Threading',
      subtitle: 'Heavy particle physics computation. Compare UI jank on main event loops with smooth Isolate execution.',
      icon: Icons.developer_board,
      color: Colors.redAccent,
      onTap: (context) => () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IsolateLabScreen()),
          ),
    ),
    _LabEntry(
      title: 'Interactive Deck',
      subtitle: 'Launch the beautiful presentation locally to learn the core rendering pipelines.',
      icon: Icons.slideshow,
      color: Colors.amberAccent,
      onTap: (context) => () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('HTML deck generated inside showcase/presentation folder! Open in browser.'),
            duration: Duration(seconds: 4),
          ),
        );
      },
    ),
    _LabEntry(
      title: 'Rendering Optimization',
      subtitle:
      'GPU Shaders, Flow layouts, PictureRecorder caching, Rive & Impeller.',
      icon: Icons.speed,
      color: Colors.cyanAccent,
      onTap: (context) => () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RenderingOptimizationScreen(),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _staggeredAnimations = List.generate(_labs.length, (index) {
      final double start = (index * 0.12).clamp(0.0, 1.0);
      final double end = (start + 0.4).clamp(0.0, 1.0);

      return CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = Responsive.gridCrossAxisCount(context);
    final aspectRatio = Responsive.gridChildAspectRatio(context);
    final titleSize = Responsive.titleFontSize(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.08),
                    blurRadius: 120,
                    spreadRadius: 80,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withValues(alpha: 0.08),
                    blurRadius: 150,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: FpsCounter(),
                    )
                  else
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ANTIGRAVITY ACADEMY',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const FpsCounter(),
                      ],
                    ),
                  SizedBox(height: isMobile ? 16 : 30),
                  Text(
                    'FLUTTER ADVANCED\nANIMATIONS LAB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  Text(
                    'A comprehensive playground showcasing micro-interactions, canvas drawing boundaries, rendering diagnostics, and background Isolates.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: isMobile ? 14 : 16,
                      height: 1.4,
                    ),
                    maxLines: isMobile ? 3 : null,
                    overflow: isMobile ? TextOverflow.ellipsis : null,
                  ),
                  SizedBox(height: isMobile ? 20 : 40),
                  Expanded(
                    child: isMobile
                        ? ListView.separated(
                            itemCount: _labs.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final lab = _labs[index];
                              return SizedBox(
                                height: 108,
                                child: _buildDashboardCard(
                                  index,
                                  title: lab.title,
                                  subtitle: lab.subtitle,
                                  icon: lab.icon,
                                  color: lab.color,
                                  onTap: lab.onTap(context),
                                ),
                              );
                            },
                          )
                        : GridView.count(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: aspectRatio * 0.95, // slight adjustment for 6 items
                            children: List.generate(_labs.length, (index) {
                              final lab = _labs[index];
                              return _buildDashboardCard(
                                index,
                                title: lab.title,
                                subtitle: lab.subtitle,
                                icon: lab.icon,
                                color: lab.color,
                                onTap: lab.onTap(context),
                              );
                            }),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    int index, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final animation = _staggeredAnimations[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double opacity = animation.value;
        final double slideOffset = (1.0 - animation.value) * 50;

        return Transform.translate(
          offset: Offset(0, slideOffset),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white24,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
