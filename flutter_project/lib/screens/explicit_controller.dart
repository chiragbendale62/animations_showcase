import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/fps_counter.dart';

class ExplicitControllerScreen extends StatefulWidget {
  const ExplicitControllerScreen({super.key});

  @override
  State<ExplicitControllerScreen> createState() => _ExplicitControllerScreenState();
}

class _ExplicitControllerScreenState extends State<ExplicitControllerScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  // Diagnostic states & controller
  late final AnimationController _diagnosticController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<Offset> _slideAnimation;
  int _unoptimizedChildBuildCount = 0;
  int _optimizedChildBuildCount = 0;

  // Translation states & controller
  late final AnimationController _translationController;
  late final Animation<double> _translationAnimation;
  double _translationDurationMs = 1500.0;

  // Staggered states & controller
  late final AnimationController _staggerController;
  late final Animation<double> _staggerOpacity;
  late final Animation<double> _staggerScale;
  late final Animation<double> _staggerSlide;
  late final Animation<double> _staggerRotate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 1. Diagnostic Animation Setup
    _diagnosticController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _diagnosticController,
        curve: const Interval(0.0, 0.45, curve: Curves.bounceOut),
      ),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2.0 * math.pi).animate(
      CurvedAnimation(
        parent: _diagnosticController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 2.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _diagnosticController,
        curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );
    _diagnosticController.repeat(reverse: true);

    // 2. Translation Animation Setup
    _translationController = AnimationController(
      duration: Duration(milliseconds: _translationDurationMs.round()),
      vsync: this,
    );
    _translationAnimation = Tween<double>(begin: -120.0, end: 120.0).animate(
      CurvedAnimation(parent: _translationController, curve: Curves.easeInOut),
    );
    _translationController.repeat(reverse: true);

    // 3. Staggered Animation Setup
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _staggerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );
    _staggerSlide = Tween<double>(begin: 120.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _staggerScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.35, 0.8, curve: Curves.elasticOut),
      ),
    );
    _staggerRotate = Tween<double>(begin: 0.25, end: 0.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start staggered sequence
    _staggerController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _diagnosticController.dispose();
    _translationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

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
          isMobile ? 'EXPLICIT' : 'EXPLICIT CONTROLLER',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purpleAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          dividerColor: Colors.white10,
          tabs: const [
            Tab(text: 'Rebuild Diagnostic'),
            Tab(text: 'Basic Translation'),
            Tab(text: 'Staggered Entry'),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: FpsCounter()),
          ),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Rebuild Diagnostic comparison
            _buildDiagnosticView(padding, isMobile),

            // Tab 2: Basic Translation with Scrubbing
            _buildTranslationView(padding, isMobile),

            // Tab 3: Staggered Profile Card entry
            _buildStaggeredView(padding, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticView(double padding, bool isMobile) {
    final useVertical = Responsive.useVerticalComparisonLayout(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          const Text(
            'PERFORMANCE COMPARISON DIAGNOSTIC',
            style: TextStyle(color: Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Static Subtree Caching',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: isMobile ? 180 : 220,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _diagnosticController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: isMobile ? 90 : 120,
                    height: isMobile ? 90 : 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.purpleAccent, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.purpleAccent, blurRadius: 24, spreadRadius: 1),
                      ],
                    ),
                    child: Icon(Icons.settings, color: Colors.white, size: isMobile ? 40 : 54),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          useVertical
              ? Column(
                  children: [
                    _buildComparisonCard(
                      title: 'A: Unoptimized Rebuild',
                      rebuildText: 'Subtree rebuilt every single frame!',
                      color: Colors.redAccent,
                      child: AnimatedBuilder(
                        animation: _diagnosticController,
                        builder: (context, _) {
                          _unoptimizedChildBuildCount++;
                          return Transform.rotate(
                            angle: _diagnosticController.value * 2 * math.pi,
                            child: _buildHeavyLeafWidget('A', _unoptimizedChildBuildCount),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonCard(
                      title: 'B: Cached Child (Optimal)',
                      rebuildText: 'Subtree cached (Built only once!)',
                      color: Colors.greenAccent,
                      child: AnimatedBuilder(
                        animation: _diagnosticController,
                        builder: (context, cachedChild) {
                          return Transform.rotate(
                            angle: _diagnosticController.value * 2 * math.pi,
                            child: cachedChild,
                          );
                        },
                        child: Builder(
                          builder: (context) {
                            _optimizedChildBuildCount++;
                            return _buildHeavyLeafWidget('B', _optimizedChildBuildCount);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildComparisonCard(
                        title: 'A: Unoptimized Rebuild',
                        rebuildText: 'Subtree rebuilt every single frame!',
                        color: Colors.redAccent,
                        child: AnimatedBuilder(
                          animation: _diagnosticController,
                          builder: (context, _) {
                            _unoptimizedChildBuildCount++;
                            return Transform.rotate(
                              angle: _diagnosticController.value * 2 * math.pi,
                              child: _buildHeavyLeafWidget('A', _unoptimizedChildBuildCount),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildComparisonCard(
                        title: 'B: Cached Child (Optimal)',
                        rebuildText: 'Subtree cached (Built only once!)',
                        color: Colors.greenAccent,
                        child: AnimatedBuilder(
                          animation: _diagnosticController,
                          builder: (context, cachedChild) {
                            return Transform.rotate(
                              angle: _diagnosticController.value * 2 * math.pi,
                              child: cachedChild,
                            );
                          },
                          child: Builder(
                            builder: (context) {
                              _optimizedChildBuildCount++;
                              return _buildHeavyLeafWidget('B', _optimizedChildBuildCount);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildTranslationView(double padding, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          const Text(
            'MANUAL TIMELINE & SPEED CONTROLLER',
            style: TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scrubbable Basic Translation',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _translationAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_translationAnimation.value, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent,
                    boxShadow: [
                      BoxShadow(color: Colors.blueAccent, blurRadius: 18, spreadRadius: 1),
                    ],
                  ),
                  child: const Icon(Icons.rocket_launch, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Explicit playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactControlBtn(
                icon: Icons.play_arrow,
                label: 'PLAY',
                onPressed: () => _translationController.forward(),
              ),
              _buildCompactControlBtn(
                icon: Icons.pause,
                label: 'PAUSE',
                onPressed: () => _translationController.stop(),
              ),
              _buildCompactControlBtn(
                icon: Icons.loop,
                label: 'LOOP',
                onPressed: () => _translationController.repeat(reverse: true),
              ),
              _buildCompactControlBtn(
                icon: Icons.history,
                label: 'REVERSE',
                onPressed: () => _translationController.reverse(),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          // Scrub control slider
          AnimatedBuilder(
            animation: _translationController,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Timeline Scrub:', style: TextStyle(color: Colors.white60, fontSize: 13)),
                      Text(
                        '${(_translationController.value * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.blueAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _translationController.value,
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.white10,
                    onChanged: (val) {
                      _translationController.value = val;
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Duration:', style: TextStyle(color: Colors.white60, fontSize: 13)),
              Text('${_translationDurationMs.round()}ms', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _translationDurationMs,
            min: 500,
            max: 4000,
            divisions: 7,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white10,
            onChanged: (val) {
              setState(() {
                _translationDurationMs = val;
                _translationController.duration = Duration(milliseconds: val.round());
                if (_translationController.isAnimating) {
                  _translationController.repeat(reverse: true);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredView(double padding, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          const Text(
            'CHOREOGRAPHED SEQUENCED TIMELINES',
            style: TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Staggered Entry Reveal',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 250,
            child: Center(
              child: AnimatedBuilder(
                animation: _staggerController,
                builder: (context, child) {
                  final angle = _staggerRotate.value * math.pi;
                  return Transform.translate(
                    offset: Offset(0, _staggerSlide.value),
                    child: Transform.rotate(
                      angle: angle,
                      child: Transform.scale(
                        scale: _staggerScale.value,
                        child: Opacity(
                          opacity: _staggerOpacity.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.15), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.pinkAccent, Colors.purpleAccent],
                              ),
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chirag Sharma',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Lead Creative Animator',
                                  style: TextStyle(color: Colors.white38, fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Current FPS', style: TextStyle(color: Colors.white38, fontSize: 11)),
                            Text('120 / 60 FPS', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'This layout cascades Opacity, Translation, Scale, and Rotation sequentially driven by a single timeline controller.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              _staggerController.reset();
              _staggerController.forward();
            },
            icon: const Icon(Icons.replay),
            label: const Text('Replay Choreography', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String rebuildText,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(rebuildText, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
          const SizedBox(height: 16),
          SizedBox(height: 80, child: Center(child: child)),
        ],
      ),
    );
  }

  Widget _buildHeavyLeafWidget(String badgeCode, int count) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, color: Colors.amberAccent, size: 20),
          const SizedBox(height: 2),
          Text(
            'B-$badgeCode: $count',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactControlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white70, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            padding: const EdgeInsets.all(10),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
