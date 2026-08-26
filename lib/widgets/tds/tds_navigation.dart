import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

/// 화면 최상단 내비게이션 바.
///
/// 디자인의 목업 상태 표시줄 대신 실제 안전 영역만큼 위를 띄운다.
/// 게임 캔버스 위에 얹을 때는 [transparent]를 켜서 배경을 비운다.
///
/// **오른쪽 끝은 비워 둔다.** 앱인토스 네비게이션 바가 이 줄과 같은 높이에
/// 더보기(...)·닫기(X)를 그리는데, 그건 미니앱이 끌 수 없는 토스 고정 영역이다.
/// 우리 버튼은 [leading]과 [leftItems]로 왼쪽에만 놓는다.
class TdsNavigation extends StatelessWidget {
  const TdsNavigation({
    super.key,
    this.title,
    this.showBack = true,
    this.onBack,
    this.leading,
    this.leftItems = const [],
    this.transparent = false,
    this.includeStatusBar = true,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;

  /// 뒤로가기 대신 왼쪽에 놓을 위젯. 닫기(X) 버튼처럼 쓴다.
  /// 지정하면 [showBack]보다 우선한다.
  final Widget? leading;

  /// [leading] 오른쪽에 이어 붙일 버튼들. 화면 액션은 전부 여기로 온다 —
  /// 오른쪽 끝은 토스 네비게이션 바 차지라 쓸 수 없다.
  final List<Widget> leftItems;

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
            for (final item in leftItems) ...[
              const SizedBox(width: TdsSpacing.gapS),
              item,
            ],
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
            // 오른쪽은 토스 네비게이션 바에 내준다.
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
