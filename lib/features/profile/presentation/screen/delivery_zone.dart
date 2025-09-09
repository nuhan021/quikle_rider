import 'package:flutter/material.dart';

class DeliveryZonePage extends StatefulWidget {
  const DeliveryZonePage({Key? key}) : super(key: key);

  @override
  State<DeliveryZonePage> createState() => _DeliveryZonePageState();
}

class _DeliveryZonePageState extends State<DeliveryZonePage> {
  String selectedLocation = '12B, Palm Grove, Versova\nMumbai, Maharashtra';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Delivery Zone',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLocation,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: Stack(
                  children: [
                    // Map placeholder
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[50],
                      ),
                      child: CustomPaint(painter: MapPainter()),
                    ),
                    // Location markers
                    const Positioned(
                      top: 80,
                      left: 120,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const Positioned(
                      top: 60,
                      right: 80,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    // Area labels
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'MOHAKHALI\nDOHS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'TOLOVI\nPOND',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'MOHAKHALI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'NADIRDOS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw some simple road-like paths
    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.4,
    );
    path1.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.5,
      size.width,
      size.height * 0.3,
    );

    final path2 = Path();
    path2.moveTo(size.width * 0.2, 0);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.3,
      size.width * 0.4,
      size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.9,
      size.width * 0.7,
      size.height,
    );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);

    // Draw some area boundaries
    paint.color = Colors.grey.withOpacity(0.2);
    paint.style = PaintingStyle.fill;

    final area1 = Path();
    area1.moveTo(size.width * 0.1, size.height * 0.1);
    area1.lineTo(size.width * 0.4, size.height * 0.1);
    area1.lineTo(size.width * 0.4, size.height * 0.4);
    area1.lineTo(size.width * 0.1, size.height * 0.4);
    area1.close();

    final area2 = Path();
    area2.moveTo(size.width * 0.6, size.height * 0.6);
    area2.lineTo(size.width * 0.9, size.height * 0.6);
    area2.lineTo(size.width * 0.9, size.height * 0.9);
    area2.lineTo(size.width * 0.6, size.height * 0.9);
    area2.close();

    canvas.drawPath(area1, paint);
    canvas.drawPath(area2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
