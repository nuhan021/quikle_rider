import 'package:flutter/material.dart';

class MapShimmer extends StatefulWidget {
  const MapShimmer({Key? key}) : super(key: key);

  @override
  State<MapShimmer> createState() => _MapShimmerState();
}

class _MapShimmerState extends State<MapShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Search bar
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: _ShimmerBox(
              animation: _controller,
              height: 52,
              radius: 8,
            ),
          ),

          // Center pin
          Center(
            child: _ShimmerBox(
              animation: _controller,
              height: 48,
              width: 48,
              radius: 24,
            ),
          ),

          // Bottom card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(animation: _controller, height: 20, width: 180),
                  const SizedBox(height: 12),
                  _ShimmerBox(animation: _controller, height: 14, width: 140),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ShimmerBox(
                          animation: _controller,
                          height: 40,
                          radius: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShimmerBox(
                          animation: _controller,
                          height: 40,
                          radius: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: 220,
            child: Column(
              children: [
                _ShimmerBox(animation: _controller, height: 40, width: 40, radius: 4),
                const SizedBox(height: 2),
                _ShimmerBox(animation: _controller, height: 40, width: 40, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final AnimationController animation;
  final double height;
  final double? width;
  final double radius;

  const _ShimmerBox({
    required this.animation,
    required this.height,
    this.width,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF8F8F8),
                Color(0xFFE8E8E8),
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}