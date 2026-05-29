import 'dart:isolate';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../utils/responsive.dart';
import '../widgets/fps_counter.dart';

class IsolateLabScreen extends StatefulWidget {
  const IsolateLabScreen({super.key});

  @override
  State<IsolateLabScreen> createState() => _IsolateLabScreenState();
}

class _IsolateLabScreenState extends State<IsolateLabScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _spinnerController;

  bool _useIsolate = true;
  bool _isComputing = false;
  String _status = 'System Idle';
  double _lastDurationMs = 0.0;

  Isolate? _backgroundIsolate;
  SendPort? _isolateSendPort;
  late final ReceivePort _uiReceivePort;

  @override
  void initState() {
    super.initState();
    _spinnerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _uiReceivePort = ReceivePort();
    _uiReceivePort.listen(_handleIsolateMessage);
    _initIsolate();
  }

  Future<void> _initIsolate() async {
    _backgroundIsolate = await Isolate.spawn(
      _isolateEntrypoint,
      _uiReceivePort.sendPort,
    );
  }

  void _handleIsolateMessage(dynamic message) {
    if (message is SendPort) {
      _isolateSendPort = message;
    } else if (message is Map<String, dynamic>) {
      final double duration = message['duration_ms'] as double;
      setState(() {
        _isComputing = false;
        _status = 'Success: Math calculated in background!';
        _lastDurationMs = duration;
      });
    }
  }

  static void _isolateEntrypoint(SendPort uiSendPort) {
    final ReceivePort isolateReceivePort = ReceivePort();
    uiSendPort.send(isolateReceivePort.sendPort);

    isolateReceivePort.listen((message) {
      if (message == 'compute_swarm') {
        final stopwatch = Stopwatch()..start();

        double sum = 0.0;
        for (int i = 0; i < 5000000; i++) {
          sum += math.sin(i.toDouble()) * math.cos(i.toDouble());
        }

        stopwatch.stop();
        uiSendPort.send({
          'result': sum,
          'duration_ms': stopwatch.elapsedMicroseconds / 1000.0,
        });
      }
    });
  }

  void _triggerStressTest() {
    setState(() {
      _isComputing = true;
      _status = 'Running intensive calculations...';
    });

    if (_useIsolate) {
      if (_isolateSendPort != null) {
        _isolateSendPort!.send('compute_swarm');
      } else {
        setState(() {
          _isComputing = false;
          _status = 'Error: Isolate not ready';
        });
      }
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final stopwatch = Stopwatch()..start();

        double sum = 0.0;
        for (int i = 0; i < 5000000; i++) {
          sum += math.sin(i.toDouble()) * math.cos(i.toDouble());
        }

        stopwatch.stop();
        setState(() {
          _isComputing = false;
          _status = 'Finished (UI frozen! Result: ${sum.toStringAsFixed(1)})';
          _lastDurationMs = stopwatch.elapsedMicroseconds / 1000.0;
        });
      });
    }
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    _backgroundIsolate?.kill();
    _uiReceivePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final isMobile = Responsive.isMobile(context);
    final stackSelectors = Responsive.sizeOf(context).width < 500;

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
          isMobile ? 'ISOLATE LAB' : 'ISOLATE THREAD LAB',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: isMobile ? 220 : 280,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Visual Frame Rate Indicator',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _spinnerController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _spinnerController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: Container(
                          width: isMobile ? 100 : 120,
                          height: isMobile ? 100 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _useIsolate ? Colors.greenAccent : Colors.redAccent,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _useIsolate
                                    ? Colors.greenAccent.withValues(alpha: 0.15)
                                    : Colors.redAccent.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: isMobile ? 64 : 80,
                                height: 6,
                                color: Colors.white70,
                              ),
                              Container(
                                width: 6,
                                height: isMobile ? 64 : 80,
                                color: Colors.white70,
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isComputing ? 'COMPUTING CHANNELS...' : 'BENCHMARK READY',
                      style: TextStyle(
                        color: _isComputing ? Colors.orangeAccent : Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATUS LOG',
                      style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    if (_lastDurationMs > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Calculation Time: ${_lastDurationMs.toStringAsFixed(1)}ms',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (stackSelectors)
                Column(
                  children: [
                    _buildSelectorBtn(
                      title: 'Background Isolate',
                      subtitle: 'Offloaded Multi-thread',
                      icon: Icons.alt_route,
                      isSelected: _useIsolate,
                      activeColor: Colors.greenAccent,
                      onTap: () => setState(() => _useIsolate = true),
                    ),
                    const SizedBox(height: 12),
                    _buildSelectorBtn(
                      title: 'Main UI Thread',
                      subtitle: 'Blocks Event Loop',
                      icon: Icons.gpp_bad,
                      isSelected: !_useIsolate,
                      activeColor: Colors.redAccent,
                      onTap: () => setState(() => _useIsolate = false),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildSelectorBtn(
                        title: 'Background Isolate',
                        subtitle: 'Offloaded Multi-thread',
                        icon: Icons.alt_route,
                        isSelected: _useIsolate,
                        activeColor: Colors.greenAccent,
                        onTap: () => setState(() => _useIsolate = true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSelectorBtn(
                        title: 'Main UI Thread',
                        subtitle: 'Blocks Event Loop',
                        icon: Icons.gpp_bad,
                        isSelected: !_useIsolate,
                        activeColor: Colors.redAccent,
                        onTap: () => setState(() => _useIsolate = false),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _useIsolate ? Colors.greenAccent : Colors.redAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isComputing ? null : _triggerStressTest,
                child: Text(
                  _useIsolate
                      ? (isMobile
                          ? 'Trigger Clean Computations'
                          : 'Trigger Clean Computations (60 FPS)')
                      : (isMobile
                          ? 'Trigger Event-Loop Block'
                          : 'Trigger Event-Loop Block (Jank / Lag)'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorBtn({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeColor.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white24,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
