import 'package:flutter/material.dart';
import 'package:quikle_rider/features/bottom_nav_bar/widgets/startup_shimmer.dart';

class StartupShimmerScreen extends StatelessWidget {
  const StartupShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: StartupShimmer(),
    );
  }
}
