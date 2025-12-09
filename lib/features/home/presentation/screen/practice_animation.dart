import 'package:flutter/material.dart';

class PracticeAnimation extends StatefulWidget {
  const PracticeAnimation({super.key});

  @override
  State<PracticeAnimation> createState() => _PracticeAnimationState();
}

class _PracticeAnimationState extends State<PracticeAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _slideController;
  late final Animation<double> _bounce;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: -100, end: 30).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _slide = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Keep the sliding container within the screen bounds.
          const slideWidth = 180.0;
          final slideTravel = (constraints.maxWidth - slideWidth) / 2;

          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _bounce,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounce.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade400,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Bouncing!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              AnimatedBuilder(
                animation: _slide,
                builder: (context, child) {
                  final dx = _slide.value * slideTravel;
                  return Transform.translate(
                    offset: Offset(100 + dx, 0),
                    child: Transform.rotate(
                      angle: 2 * 3.141592653589793 / 3, // 120 degrees in radians
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: slideWidth,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.teal.shade400,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Runner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
