import 'package:flutter/material.dart';

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final ShapeBorder shapeBorder;

  const ShimmerCard({
    Key? key,
    this.width,
    this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  }) : super(key: key);

  const ShimmerCard.circular({
    Key? key,
    required double diameter,
    this.shapeBorder = const CircleBorder(),
  })  : width = diameter,
        height = diameter,
        super(key: key);

  const ShimmerCard.rectangular({
    Key? key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.grey[400]!,
        shape: shapeBorder,
      ),
    );
  }
}
