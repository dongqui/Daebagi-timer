import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';

/// TDS 로더 — 꼬리가 흐려지는 링이 도는 형태.
///
/// Material의 `CircularProgressIndicator`와 달리 호의 길이가 변하지 않고
/// 회전만 한다. 인트로 화면에서 36px로 쓴다.
class TdsLoader extends StatefulWidget {
  const TdsLoader({
    super.key,
    this.size = 36,
    this.color = TdsColors.onCanvasStrong,
  });

  final double size;
  final Color color;

  @override
  State<TdsLoader> createState() => _TdsLoaderState();
}

class _TdsLoaderState extends State<TdsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _RingPainter(widget.color),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width / 9;
    final rect = Offset.zero & size;
    final inset = rect.deflate(stroke / 2);

    // 시작점은 투명, 끝점은 불투명. 회전하면 꼬리가 뒤로 흐르는 것처럼 보인다.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0), color],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(inset, -math.pi / 2, math.pi * 1.85, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.color != color;
}
