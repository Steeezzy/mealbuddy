import 'package:flutter/material.dart';

class MealBuddyLogo extends StatelessWidget {
  const MealBuddyLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 120,  // Increased height
        width: 120,   // Increased width
        child: CustomPaint(
          size: Size(120, 120),  // Matched size with container
          painter: MealBuddyPainter(),
        ),
      ),
    );
  }
}

class MealBuddyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Logo Background
    paint.color = const Color(0xFF8BC34A);
    final logoRect = RRect.fromLTRBR(
        size.width * 0.2,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.8,
        Radius.circular(15));
    canvas.drawRRect(logoRect, paint);

    // Plate Icon
    paint.color = const Color(0xFFF0F0F0);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.3, paint);
    paint.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5), size.width * 0.25, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}