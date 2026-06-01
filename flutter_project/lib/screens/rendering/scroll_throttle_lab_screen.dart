import 'package:flutter/material.dart';

class ScrollThrottleLabScreen extends StatefulWidget {
  const ScrollThrottleLabScreen({super.key});

  @override
  State<ScrollThrottleLabScreen> createState() =>
      _ScrollThrottleLabScreenState();
}

class _ScrollThrottleLabScreenState
    extends State<ScrollThrottleLabScreen> {
  bool useOptimizedMode = true;

  int badRebuildCount = 0;
  int optimizedRebuildCount = 0;

  late ScrollController _scrollController;

  final ValueNotifier<double> parallaxOffset =
  ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (useOptimizedMode) {
        parallaxOffset.value =
            _scrollController.offset;
      } else {
        setState(() {
          badRebuildCount++;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    parallaxOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    optimizedRebuildCount++;

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "SCROLL THROTTLING LAB",
            style: TextStyle(
              color: Colors.greenAccent,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: metricCard(
                    "Bad Rebuilds",
                    "$badRebuildCount",
                    Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: metricCard(
                    "Optimized",
                    "$optimizedRebuildCount",
                    Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SwitchListTile(
            value: useOptimizedMode,
            activeColor: Colors.greenAccent,
            title: Text(
              useOptimizedMode
                  ? "Optimized ValueNotifier"
                  : "Full setState Rebuild",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onChanged: (v) {
              setState(() {
                useOptimizedMode = v;
              });
            },
          ),

          const SizedBox(height: 10),

          Expanded(
            child: useOptimizedMode
                ? buildOptimizedView()
                : buildBadView(),
          ),
        ],
      ),
    );
  }

  Widget metricCard(
      String title,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBadView() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.redAccent
                .withOpacity(.15),
          ),
        ),

        ListView.builder(
          controller: _scrollController,
          itemCount: 50,
          itemBuilder: (_, index) {
            return Container(
              margin:
              const EdgeInsets.all(12),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  "Item $index",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  Widget buildOptimizedView() {
    return Stack(
      children: [
        ValueListenableBuilder<double>(
          valueListenable: parallaxOffset,
          builder: (_, offset, __) {
            return Transform.translate(
              offset: Offset(
                0,
                -(offset * .25),
              ),
              child: Container(
                height: 250,
                decoration:
                const BoxDecoration(
                  gradient:
                  LinearGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.purpleAccent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        ListView.builder(
          controller: _scrollController,
          itemCount: 50,
          itemBuilder: (_, index) {
            return Container(
              margin:
              const EdgeInsets.all(12),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  "Item $index",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}