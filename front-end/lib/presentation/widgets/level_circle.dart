import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/question_model.dart';

class LevelCircle extends PositionComponent with TapCallbacks {
  final List<Question> questions;
  final Function(TapDownEvent)? onTap;
  final double radius;
  final int levelNumber;
  bool isCompleted = false;

  LevelCircle({
    required Vector2 position,
    required this.radius,
    required this.questions,
    required this.levelNumber,
    required this.onTap,
    required int priority,
  }) : super(
          position: position,
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
          priority: priority,
        );

  set isAccessible(bool value) {
    _isAccessible = value;
    // Force re-render when accessibility changes
    if (isMounted) {
      debugPrint('Level $levelNumber accessibility updated to: $value');
    }
  }

  bool get isAccessible => _isAccessible;
  bool _isAccessible = false;

  @override
  void render(Canvas canvas) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(radius, radius + 2),
      radius,
      shadowPaint,
    );

    final basePaint = Paint()
      ..color = isCompleted
          ? const Color(0xFF66B51B)
          : isAccessible
              ? const Color(0xFFFFD700)
              : Colors.grey;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      basePaint,
    );

    // Draw inner circle for 3D effect
    final innerPaint = Paint()
      ..color = isAccessible ? (isCompleted ? const Color(0xFF7BCB2B) : const Color(0xFF7D74FF)) : Colors.grey.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(radius, radius),
      radius * 0.85,
      innerPaint,
    );

    // Draw level number
    final textPainter = TextPainter(
      text: TextSpan(
        text: levelNumber.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );

    if (isCompleted) {
      final checkmarkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path()
        ..moveTo(radius - 8, radius)
        ..lineTo(radius - 3, radius + 5)
        ..lineTo(radius + 8, radius - 5);
      canvas.drawPath(path, checkmarkPaint);
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (isAccessible) {
      debugPrint('Tap detected on Level $levelNumber');
      onTap?.call(event);
      return true;
    }
    debugPrint('Level $levelNumber is not accessible');
    return false;
  }

  @override
  bool containsPoint(Vector2 point) {
    final circleCenter = Vector2(radius, radius);
    final centerOffset = size / 2;
    final anchorOffset = Vector2(anchor.x * size.x, anchor.y * size.y);
    final localPoint = point - position + centerOffset - anchorOffset;
    final distance = circleCenter.distanceTo(localPoint);
    final isInside = distance <= radius * 1.5; // Increased tap area
    if (isInside) {
      debugPrint('Tap detected inside Level $levelNumber circle');
    }
    return isInside;
  }
}
