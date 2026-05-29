import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/fps_counter.dart';

class HeroProject {
  const HeroProject({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    required this.specs,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> specs;
}

class HeroShowcaseScreen extends StatelessWidget {
  const HeroShowcaseScreen({super.key});

  static const List<HeroProject> _projects = [
    HeroProject(
      id: 'nebula_voyager',
      title: 'Nebula Voyager',
      category: 'DEEP SPACE EXPEDITIONS',
      description: 'An advanced interstellar exploration node designed for long-range celestial charting and deep-space telemetry gathering across distant star systems.',
      icon: Icons.explore,
      color: Colors.pinkAccent,
      specs: ['Warp Engine: v9.4', 'Range: 800 LY', 'Telemetry: Passive Array'],
    ),
    HeroProject(
      id: 'quantum_reactor',
      title: 'Quantum Reactor',
      category: 'SUB-ATOMIC POWER',
      description: 'A stable sub-atomic containment matrix producing massive clean energy outputs by tapping into quantum vacuum fluctuations and localized particle superpositions.',
      icon: Icons.wb_iridescent,
      color: Colors.cyanAccent,
      specs: ['Power Output: 4.8 GW', 'Efficiency: 99.8%', 'Containment: Magnetostatic'],
    ),
    HeroProject(
      id: 'horizon_synth',
      title: 'Horizon Synth',
      category: 'AUDIO SIGNAL ENGINE',
      description: 'A dual-phase analog signal wave engine that synthesizes cinematic acoustic textures, harmonic reverbs, and resonant bass structures in real-time.',
      icon: Icons.music_note,
      color: Colors.orangeAccent,
      specs: ['Channels: 64 Wave', 'Filter: Lowpass Resonant', 'Latency: <1.5 ms'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isMobile ? 'HERO FLOW' : 'HERO TRANSITIONS',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: FpsCounter()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SHARED ELEMENT NAVIGATION CHANNELS',
                style: TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Project Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap any project card to launch a shared element Hero flight transition.\nThe detailed page reveals content cascading dynamically.',
                style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 28),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _projects.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  return _buildProjectCard(context, project);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, HeroProject project) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              reverseTransitionDuration: const Duration(milliseconds: 600),
              pageBuilder: (context, animation, secondaryAnimation) {
                return HeroDetailScreen(project: project);
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                  child: child,
                );
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
          ),
          child: Row(
            children: [
              // Hero Icon Area
              Hero(
                tag: 'project_icon_${project.id}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: project.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: project.color.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Icon(project.icon, color: project.color, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.category,
                      style: TextStyle(color: project.color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    // Hero Title Area
                    Hero(
                      tag: 'project_title_${project.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          project.title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project.description,
                      style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroDetailScreen extends StatefulWidget {
  const HeroDetailScreen({super.key, required this.project});

  final HeroProject project;

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _descOpacity;
  late final Animation<double> _specsOpacity;
  late final Animation<double> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Staggered intervals starting after the main Hero transition flights settle
    _descOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _specsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _buttonSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Fire entrance timeline
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = Responsive.horizontalPadding(context);
    final project = widget.project;

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Stack(
        children: [
          // Background Glow Node
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: project.color.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: project.color.withValues(alpha: 0.08),
                    blurRadius: 100,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Custom Header bar
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding - 8),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Master Flight 1: Hero Icon
                        Center(
                          child: Hero(
                            tag: 'project_icon_${project.id}',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: project.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: project.color.withValues(alpha: 0.35), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: project.color.withValues(alpha: 0.15),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(project.icon, color: project.color, size: 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                project.category,
                                style: TextStyle(color: project.color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                              const SizedBox(height: 8),
                              // Master Flight 2: Hero Title
                              Hero(
                                tag: 'project_title_${project.id}',
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    project.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: Colors.white10, height: 1),
                        const SizedBox(height: 24),

                        // Staggered Cascade Node 1: Description
                        AnimatedBuilder(
                          animation: _entranceController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _descOpacity.value,
                              child: child,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'OVERVIEW',
                                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.description,
                                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.45),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Staggered Cascade Node 2: Specs badges
                        AnimatedBuilder(
                          animation: _entranceController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _specsOpacity.value,
                              child: child,
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SPECIFICATIONS',
                                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: project.specs.map((spec) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                    ),
                                    child: Text(
                                      spec,
                                      style: TextStyle(color: project.color, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Staggered Cascade Node 3: Interactive Button slide
                        AnimatedBuilder(
                          animation: _entranceController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _buttonSlide.value),
                              child: Opacity(
                                opacity: _entranceController.value.clamp(0.0, 1.0),
                                child: child,
                              ),
                            );
                          },
                          child: Center(
                            child: SizedBox(
                              width: size.width * 0.7,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: project.color,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Initializing system connection for ${project.title}...'),
                                      backgroundColor: const Color(0xFF0F172A),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'ENGAGE SYSTEMS',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
