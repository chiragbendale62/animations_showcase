import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/fps_counter.dart';

class ImplicitPlayground extends StatefulWidget {
  const ImplicitPlayground({super.key});

  @override
  State<ImplicitPlayground> createState() => _ImplicitPlaygroundState();
}

class _ImplicitPlaygroundState extends State<ImplicitPlayground> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Simple sandbox states
  double _width = 160.0;
  double _height = 160.0;
  double _borderRadius = 16.0;
  double _opacity = 1.0;
  double _angle = 0.0;
  Color _color = Colors.blueAccent;

  // Chained states
  bool _chainedToggled = false;

  Curve _selectedCurve = Curves.easeOutBack;
  int _durationMs = 600;

  final Map<String, Curve> _curves = {
    'Ease Out Back': Curves.easeOutBack,
    'Linear': Curves.linear,
    'Decelerate': Curves.decelerate,
    'Bounce Out': Curves.bounceOut,
    'Elastic Out': Curves.elasticOut,
    'Ease In Out': Curves.easeInOut,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _randomizeSimple() {
    setState(() {
      _width = _width == 160.0 ? 220.0 : 160.0;
      _height = _height == 160.0 ? 220.0 : 160.0;
      _borderRadius = _borderRadius == 16.0 ? 60.0 : 16.0;
      _opacity = _opacity == 1.0 ? 0.3 : 1.0;
      _angle = _angle == 0.0 ? math.pi / 2 : 0.0;
      _color = _color == Colors.blueAccent ? Colors.purpleAccent : Colors.blueAccent;
    });
  }

  void _toggleChained() {
    setState(() {
      _chainedToggled = !_chainedToggled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.horizontalPadding(context);

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
          isMobile ? 'IMPLICIT' : 'IMPLICIT SANDBOX',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          dividerColor: Colors.white10,
          tabs: const [
            Tab(text: 'Simple Sandbox'),
            Tab(text: 'Chained Properties'),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Simple Sandbox Tab
                      _buildSimpleSandbox(padding, isMobile),

                      // Chained Properties Tab
                      _buildChainedDemo(padding, isMobile),
                    ],
                  ),
                ),
                _buildControls(padding, constraints, isMobile),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimpleSandbox(double padding, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PROPERTY-DRIVEN AUTO INTERPOLATION',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Implicit Sandbox',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 240,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: _angle),
                  duration: Duration(milliseconds: _durationMs),
                  curve: _selectedCurve,
                  builder: (context, angle, child) {
                    return Transform.rotate(
                      angle: angle,
                      child: child,
                    );
                  },
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: Duration(milliseconds: _durationMs),
                    curve: _selectedCurve,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: _durationMs),
                      curve: _selectedCurve,
                      width: isMobile ? _width.clamp(120, 180) : _width,
                      height: isMobile ? _height.clamp(120, 180) : _height,
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(_borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: _color.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.animation,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: _randomizeSimple,
              icon: const Icon(Icons.shuffle),
              label: Text(
                isMobile ? 'Animate' : 'Randomize State & Trigger Interpolation',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainedDemo(double padding, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NESTED STATE REBUILD CHANNELS',
              style: TextStyle(
                color: Colors.purpleAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chained Implicit Animations',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'AnimatedContainer size and color triggers a nested AnimatedOpacity\nand AnimatedRotation to rotate and fade in parallel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 240,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleChained,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: _durationMs),
                    curve: _selectedCurve,
                    width: _chainedToggled ? 200 : 130,
                    height: _chainedToggled ? 200 : 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _chainedToggled
                            ? [Colors.blueAccent, Colors.purpleAccent]
                            : [Colors.indigo, Colors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(_chainedToggled ? 40 : 12),
                      boxShadow: [
                        BoxShadow(
                          color: (_chainedToggled ? Colors.purpleAccent : Colors.indigo)
                              .withValues(alpha: 0.35),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedRotation(
                        turns: _chainedToggled ? 1.0 : 0.0,
                        duration: Duration(milliseconds: _durationMs),
                        curve: _selectedCurve,
                        child: AnimatedOpacity(
                          opacity: _chainedToggled ? 1.0 : 0.3,
                          duration: Duration(milliseconds: _durationMs),
                          curve: _selectedCurve,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amberAccent,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap Me',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusBadge(
                  label: 'Container Size',
                  value: _chainedToggled ? '200px' : '130px',
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(
                  label: 'Child Opacity',
                  value: _chainedToggled ? '1.0' : '0.3',
                  color: Colors.purpleAccent,
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(
                  label: 'Child Rotation',
                  value: _chainedToggled ? '360°' : '0°',
                  color: Colors.tealAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildControls(double padding, BoxConstraints constraints, bool isMobile) {
    return Container(
      constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.42),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ANIMATION PARAMETERS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            if (isMobile) ...[
              const Text('Selected Curve:', style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 8),
              _buildCurveDropdown(),
            ] else
              Row(
                children: [
                  const Text('Selected Curve:', style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCurveDropdown()),
                ],
              ),
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Duration:', style: TextStyle(color: Colors.white60, fontSize: 13)),
                Text(
                  '${_durationMs}ms',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            Slider(
              value: _durationMs.toDouble(),
              min: 100,
              max: 2000,
              divisions: 19,
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.white10,
              onChanged: (val) {
                setState(() {
                  _durationMs = val.round();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurveDropdown() {
    return DropdownButton<Curve>(
      isExpanded: true,
      dropdownColor: const Color(0xFF0F172A),
      value: _selectedCurve,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      underline: Container(),
      items: _curves.entries.map((entry) {
        return DropdownMenuItem<Curve>(
          value: entry.value,
          child: Text(entry.key),
        );
      }).toList(),
      onChanged: (Curve? value) {
        if (value != null) {
          setState(() {
            _selectedCurve = value;
          });
        }
      },
    );
  }
}
