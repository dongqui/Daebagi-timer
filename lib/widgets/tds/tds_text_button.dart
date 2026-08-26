import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';

enum TdsTextButtonSize { s, m, l }

enum TdsTextButtonColor { brand, neutral }

/// 배경 없는 보조 액션. 주 버튼 아래 놓이는 "기록 보기" 같은 링크성 동작에 쓴다.
class TdsTextButton extends StatelessWidget {
  const TdsTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = TdsTextButtonSize.l,
    this.color = TdsTextButtonColor.brand,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TdsTextButtonSize size;
  final TdsTextButtonColor color;

  /// 가로를 꽉 채우고 라벨을 가운데 정렬한다. `BottomCTA`의 하단 항목에서 쓴다.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fontSize = switch (size) {
      TdsTextButtonSize.s => 13.0,
      TdsTextButtonSize.m => 15.0,
      TdsTextButtonSize.l => 17.0,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Opacity(
        opacity: enabled ? 1 : 0.3,
        child: SizedBox(
          width: fullWidth ? double.infinity : null,
          child: Text(
            label,
            textAlign: fullWidth ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: color == TdsTextButtonColor.brand
                  ? TdsColors.brandText
                  : TdsColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
