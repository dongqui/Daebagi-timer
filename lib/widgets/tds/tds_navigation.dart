import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

/// 화면 최상단 내비게이션 바.
///
/// 디자인의 목업 상태 표시줄 대신 실제 안전 영역만큼 위를 띄운다.
/// 게임 캔버스 위에 얹을 때는 [transparent]를 켜서 배경을 비운다.
class TdsNavigation extends StatelessWidget {
  const TdsNavigation({
    super.key,
    this.title,
    this.showBack = true,
    this.onBack,
    this.leading,
    this.rightItems = const [],
    this.transparent = false,
    this.includeStatusBar = true,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;

  /// 뒤로가기 대신 왼쪽에 놓을 위젯. 닫기(X) 버튼처럼 쓴다.
  /// 지정하면 [showBack]보다 우선한다.
  final Widget? leading;

  final List<Widget> rightItems;
  final bool transparent;

  /// 상단 안전 영역만큼 여백을 더할지. 스크롤 뷰 안에 넣을 때는 끈다.
  final bool includeStatusBar;

  @override
  Widget build(BuildContext context) {
    final topInset =
        includeStatusBar ? MediaQuery.paddingOf(context).top : 0.0;

    return Container(
      width: double.infinity,
      color: transparent ? null : TdsColors.background,
      padding: EdgeInsets.only(top: topInset),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            const SizedBox(width: 6),
            if (leading != null)
              leading!
            else if (showBack)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: Semantics(
                  button: true,
                  label: '뒤로',
                  child: const SizedBox.square(
                    dimension: TdsSize.iconButtonL,
                    child: Center(
                      child: CustomPaint(
                        size: Size(10, 17.5),
                        painter: _BackChevronPainter(),
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox.square(dimension: TdsSize.iconButtonL),
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: TdsColors.textStrong,
                      ),
                    ),
            ),
            for (final item in rightItems) ...[
              item,
              const SizedBox(width: TdsSpacing.gapM),
            ],
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  const _BackChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = TdsColors.textStrong
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width - 1.1, 1.1)
      ..lineTo(1.1, size.height / 2)
      ..lineTo(size.width - 1.1, size.height - 1.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BackChevronPainter oldDelegate) => false;
}
