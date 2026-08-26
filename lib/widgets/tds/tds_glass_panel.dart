import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

/// 게임 캔버스 위에 떠 있는 유리 패널.
///
/// 디자인에서 홈 메뉴 버튼, 타이머 컨트롤 바, 백색소음 패널에 반복해서 쓰는
/// 조합(반투명 채움 + 배경 블러 + 안쪽 1px 링)을 한 곳에 모았다.
/// TDS 정식 컴포넌트는 아니지만 네 군데에서 같은 값을 쓰므로 위젯으로 뺀다.
class TdsGlassPanel extends StatelessWidget {
  const TdsGlassPanel({
    super.key,
    required this.child,
    this.borderRadius = TdsRadius.full,
    this.padding = EdgeInsets.zero,
    this.elevated = false,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  /// 바닥에서 확실히 떠 보여야 할 때 (컨트롤 바, 백색소음 패널) 드롭섀도를 얹는다.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x8C000000),
                  blurRadius: 30,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: TdsBlur.glassSigma,
            sigmaY: TdsBlur.glassSigma,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: TdsColors.glassFill,
              borderRadius: radius,
              // CSS의 `inset 0 0 0 1px`에 해당. Border는 안쪽으로 그려진다.
              border: Border.all(color: TdsColors.glassRing, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
