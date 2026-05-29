import 'package:flutter/material.dart';

class FpsCounter extends StatefulWidget {
  const FpsCounter({super.key});

  @override
  State<FpsCounter> createState() => _FpsCounterState();
}

class _FpsCounterState extends State<FpsCounter> {
  late final ValueNotifier<double> _fpsNotifier;
  Duration _lastFrameTime = Duration.zero;
  final List<double> _frameTimes = [];

  @override
  void initState() {
    super.initState();
    _fpsNotifier = ValueNotifier<double>(60.0);
    // Bind ticker post frame listener
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration timestamp) {
    if (!mounted) return;

    if (_lastFrameTime != Duration.zero) {
      final double deltaMs = (timestamp - _lastFrameTime).inMicroseconds / 1000.0;
      if (deltaMs > 0) {
        final double instantFps = 1000.0 / deltaMs;
        _frameTimes.add(instantFps);
        
        // Cache sliding window of 20 frames for smoothing
        if (_frameTimes.length > 20) {
          _frameTimes.removeAt(0);
        }
        
        final double avgFps = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
        _fpsNotifier.value = avgFps;
      }
    }
    
    _lastFrameTime = timestamp;
    WidgetsBinding.instance.addPostFrameCallback(_tick);
  }

  @override
  void dispose() {
    _fpsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _fpsNotifier,
      builder: (context, fps, child) {
        // Round the value for readability
        final int roundedFps = fps.round().clamp(0, 120);
        Color color = Colors.greenAccent;
        
        if (roundedFps < 30) {
          color = Colors.redAccent;
        } else if (roundedFps < 50) {
          color = Colors.orangeAccent;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: color, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$roundedFps FPS',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

