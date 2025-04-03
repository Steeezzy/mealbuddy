import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8BC34A),
        title: Text('About Us'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomPaint(
        size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
        painter: MealBuddyPainter(),
      ),
    );
  }
}

class MealBuddyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Background green rectangle
    paint.color = Color(0xFF76B041);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 120), paint);

    // Semi-transparent overlay
    paint.color = Color(0x99EEEEEE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 120), paint);

    // Logo rectangle
    paint.color = Color(0xFF76B041);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(30, 150, 100, 100), Radius.circular(15)),
      paint,
    );

    // Logo circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(80, 200), 35, paint);

    // Company name
    final titlePainter = TextPainter(
      text: TextSpan(
        text: 'MEALBUDDY',
        style: TextStyle(
          color: Color(0xFF333333),
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(150, 200));

    // Developer details
    final developers = [
      'Ajun K Saji - ajunkizhakkeparambil@gmail.com',
      'Alen Vincent G - alankochupally@gmail.com',
      'John Joseph - johnjoseph2212@gmail.com',
      'Karthik J - karthiknedumalayil@gmail.com'
    ];

    double yOffset = 460;
    for (var dev in developers) {
      final developerPainter = TextPainter(
        text: TextSpan(
          text: dev,
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      developerPainter.layout();
      developerPainter.paint(canvas, Offset(30, yOffset));
      yOffset += 30;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}