import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GeometricArt extends StatelessWidget {
  const GeometricArt({required this.seed, required this.size, super.key});

  final int seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GeometricArtPainter(seed));
  }
}

class _GeometricArtPainter extends CustomPainter {
  const _GeometricArtPainter(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.purple, AppColors.cyan, AppColors.gold],
      ).createShader(rect);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pi / 4 + seed * 0.02);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: radius * 1.5, height: radius * 1.5), const Radius.circular(26)),
      fill,
    );
    canvas.restore();

    final line = Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 12; i++) {
      final angle = pi * 2 * i / 12;
      final start = center + Offset(cos(angle), sin(angle)) * radius * 0.18;
      final end = center + Offset(cos(angle), sin(angle)) * radius * 0.7;
      canvas.drawLine(start, end, line);
      canvas.drawCircle(end, 7, line);
    }
    canvas.drawCircle(center, radius * 0.2, Paint()..color = Colors.black.withValues(alpha: 0.34));
  }

  @override
  bool shouldRepaint(covariant _GeometricArtPainter oldDelegate) => oldDelegate.seed != seed;
}
