import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';

enum TdsArrowDirection { left, right, up, down }

/// TDS 화살표(셰브론). 기간 이동 버튼 등에서 쓴다.
class TdsArrow extends StatelessWidget {
  const TdsArrow({
    super.key,
    this.direction = TdsArrowDirection.right,
    this.size = 22,
    this.color = TdsColors.iconTertiary,
  });

  final TdsArrowDirection direction;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ChevronPainter(direction: direction, color: color),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.direction, required this.color});

  final TdsArrowDirection direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 오른쪽을 향하는 셰브론을 그린 뒤 방향에 맞춰 회전시킨다.
    final w = size.width;
    final path = Path()
      ..moveTo(w * 0.4, w * 0.26)
      ..lineTo(w * 0.66, w * 0.5)
      ..lineTo(w * 0.4, w * 0.74);

    final quarterTurns = switch (direction) {
      TdsArrowDirection.right => 0,
      TdsArrowDirection.down => 1,
      TdsArrowDirection.left => 2,
      TdsArrowDirection.up => 3,
    };

    canvas
      ..save()
      ..translate(w / 2, w / 2)
      ..rotate(quarterTurns * 1.5707963267948966)
      ..translate(-w / 2, -w / 2)
      ..drawPath(path, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.direction != direction || oldDelegate.color != color;
}
