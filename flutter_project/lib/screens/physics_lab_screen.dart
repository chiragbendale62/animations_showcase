import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import '../utils/responsive.dart';
import '../widgets/fps_counter.dart';

class PhysicsLabScreen extends StatefulWidget {
  const PhysicsLabScreen({super.key});

  @override
  State<PhysicsLabScreen> createState() => _PhysicsLabScreenState();
}

class _PhysicsLabScreenState extends State<PhysicsLabScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  // 1. Spring Snap-Back states
  late final AnimationController _springController;
  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _alignmentAnimation;

  // 2. Friction Fling states
  Offset _puckPosition = const Offset(130, 100);
  Offset _puckVelocity = Offset.zero;
  Ticker? _flingTicker;
  FrictionSimulation? _frictionSimX;
  FrictionSimulation? _frictionSimY;
  final double _puckRadius = 24.0;
  final Size _canvasSize = const Size(300, 240);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Spring Controller Setup
    _springController = AnimationController(vsync: this);
    _springController.addListener(() {
      setState(() {
        _dragAlignment = _alignmentAnimation.value;
      });
    });

    // Fling Ticker Setup
    _flingTicker = createTicker(_handleFlingTick);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _springController.dispose();
    _flingTicker?.dispose();
    super.dispose();
  }

  // --- Spring Snap-Back Math ---
  void _runSpringAnimation(Offset pixelsPerSecond, Size boxSize) {
    // Convert velocity to unit alignment space
    final unitsPerSecondX = pixelsPerSecond.dx / (boxSize.width / 2);
    final unitsPerSecondY = pixelsPerSecond.dy / (boxSize.height / 2);
    final unitVelocity = Offset(unitsPerSecondX, unitsPerSecondY);

    const spring = SpringDescription(
      mass: 1.0,
      stiffness: 140.0,
      damping: 12.0,
    );

    // We can drive alignment tween mapping progress
    _alignmentAnimation = _springController.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );

    // We can animate standard controller or run custom simulation
    _springController.animateWith(
      SpringSimulation(
        spring,
        0.0,
        1.0,
        -unitVelocity.distance.clamp(0.0, 20.0),
      ),
    );
  }

  // --- Friction Fling Collision Loop ---
  void _startFrictionFling(Offset velocity) {
    _flingTicker?.stop();

    const double frictionCoef = 0.12; // fluid drag
    _frictionSimX = FrictionSimulation(frictionCoef, _puckPosition.dx, velocity.dx);
    _frictionSimY = FrictionSimulation(frictionCoef, _puckPosition.dy, velocity.dy);

    _flingTicker?.start();
  }

  void _handleFlingTick(Duration elapsed) {
    if (_frictionSimX == null || _frictionSimY == null) return;

    final double timeSec = elapsed.inMicroseconds / 1000000.0;
    double newX = _frictionSimX!.x(timeSec);
    double newY = _frictionSimY!.x(timeSec);
    double velX = _frictionSimX!.dx(timeSec);
    double velY = _frictionSimY!.dx(timeSec);

    final double minX = _puckRadius;
    final double maxX = _canvasSize.width - _puckRadius;
    final double minY = _puckRadius;
    final double maxY = _canvasSize.height - _puckRadius;

    bool collision = false;

    // Boundary checks with elastic bounce
    if (newX < minX) {
      newX = minX;
      velX = -velX * 0.75; // reverse and damp
      collision = true;
    } else if (newX > maxX) {
      newX = maxX;
      velX = -velX * 0.75;
      collision = true;
    }

    if (newY < minY) {
      newY = minY;
      velY = -velY * 0.75;
      collision = true;
    } else if (newY > maxY) {
      newY = maxY;
      velY = -velY * 0.75;
      collision = true;
    }

    setState(() {
      _puckPosition = Offset(newX, newY);
      _puckVelocity = Offset(velX, velY);
    });

    if (collision) {
      // Recreate simulations starting at current boundary with reversed velocity
      _startFrictionFling(_puckVelocity);
    }

    // Stop ticker if puck has decelerated to a crawl
    if (_puckVelocity.distance < 8.0) {
      _flingTicker?.stop();
      setState(() {
        _puckVelocity = Offset.zero;
      });
    }
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
          isMobile ? 'PHYSICS LAB' : 'PHYSICS & GESTURE LAB',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.greenAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          dividerColor: Colors.white10,
          tabs: const [
            Tab(text: 'Spring Snap-Back'),
            Tab(text: 'Friction Fling'),
            Tab(text: 'Scroll Physics'),
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
          physics: const NeverScrollableScrollPhysics(), // Prevent horizontal swipe gesture overlap with flinging
          children: [
            _buildSpringView(padding, isMobile),
            _buildFrictionView(padding, isMobile),
            _buildScrollView(padding, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildSpringView(double padding, bool isMobile) {
    final size = MediaQuery.of(context).size;
    final boxWidth = isMobile ? size.width * 0.85 : 400.0;
    final boxHeight = isMobile ? 260.0 : 320.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Text(
              'DAMPED SPRING SIMULATION (HOOKES LAW)',
              style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Drag & Snap Card',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Release the card with drag momentum to watch the spring description\n(mass: 1.0, stiffness: 140, damping: 12) animate back with velocity tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 24),
            Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bounding center indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: const Center(child: Icon(Icons.add, color: Colors.greenAccent, size: 16)),
                  ),
                  GestureDetector(
                    onPanDown: (details) {
                      _springController.stop();
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _dragAlignment += Alignment(
                          details.delta.dx / (boxWidth / 2),
                          details.delta.dy / (boxHeight / 2),
                        );
                      });
                    },
                    onPanEnd: (details) {
                      _runSpringAnimation(details.velocity.pixelsPerSecond, Size(boxWidth, boxHeight));
                    },
                    child: Align(
                      alignment: _dragAlignment,
                      child: Container(
                        width: 130,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.12),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swipe, color: Colors.greenAccent, size: 28),
                            SizedBox(height: 6),
                            Text(
                              'DRAG ME',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Current Offset Alignment: x: ${_dragAlignment.x.toStringAsFixed(2)}, y: ${_dragAlignment.y.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrictionView(double padding, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Text(
              'FLUID INERTIAL FRICTION DECELERATION',
              style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Air Hockey Friction Fling',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Swipe the puck inside the board to fling it. The physics engine computes\nexponential fluid deceleration and elastic rebound off boundaries.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 24),
            Container(
              width: _canvasSize.width,
              height: _canvasSize.height,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
              ),
              child: Stack(
                children: [
                  // Bouncing Board Lines
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: _canvasSize.width / 2 - 1,
                    child: Container(width: 2, color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _canvasSize.height / 2 - 1,
                    child: Container(height: 2, color: Colors.white.withValues(alpha: 0.04)),
                  ),
                  // The Swipable Puck
                  Positioned(
                    left: _puckPosition.dx - _puckRadius,
                    top: _puckPosition.dy - _puckRadius,
                    child: GestureDetector(
                      onPanDown: (details) {
                        _flingTicker?.stop();
                        setState(() {
                          _puckVelocity = Offset.zero;
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          final double newX = (_puckPosition.dx + details.delta.dx)
                              .clamp(_puckRadius, _canvasSize.width - _puckRadius);
                          final double newY = (_puckPosition.dy + details.delta.dy)
                              .clamp(_puckRadius, _canvasSize.height - _puckRadius);
                          _puckPosition = Offset(newX, newY);
                        });
                      },
                      onPanEnd: (details) {
                        _startFrictionFling(details.velocity.pixelsPerSecond);
                      },
                      child: Container(
                        width: _puckRadius * 2,
                        height: _puckRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(color: Colors.greenAccent, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPhysicsInfoBadge(
                  label: 'POS',
                  value: 'x:${_puckPosition.dx.toStringAsFixed(0)}, y:${_puckPosition.dy.toStringAsFixed(0)}',
                ),
                const SizedBox(width: 12),
                _buildPhysicsInfoBadge(
                  label: 'VEL',
                  value: '${_puckVelocity.distance.toStringAsFixed(0)} px/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollView(double padding, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Column(
        children: [
          const Text(
            'BEHAVIOR COMPARATIVE SIMULATOR',
            style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 6),
          const Text(
            'Scroll Physics Comparison',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // iOS Bouncing Scroll
                Expanded(
                  child: Column(
                    children: [
                      _buildScrollBadge(title: 'iOS Bouncing', subtitle: 'Elastic overscroll', active: true),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                          ),
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: 15,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) => _buildScrollItem('iOS Item ${index + 1}', Colors.cyanAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Android Clamping Scroll
                Expanded(
                  child: Column(
                    children: [
                      _buildScrollBadge(title: 'Android Clamping', subtitle: 'Solid edge clamp', active: false),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                          ),
                          child: ListView.separated(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: 15,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) => _buildScrollItem('Android Item ${index + 1}', Colors.greenAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollBadge({required String title, required String subtitle, required bool active}) {
    final color = active ? Colors.cyanAccent : Colors.greenAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildPhysicsInfoBadge({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
