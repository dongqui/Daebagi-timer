import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

enum TdsSegmentedSize { s, l }

/// 같은 목록을 보는 방식을 바꾸는 컨트롤 (기간, 유형).
///
/// 트랙은 옅은 회색이고 선택된 칸만 배경색 알약으로 떠오른다.
class TdsSegmentedControl<T> extends StatelessWidget {
  const TdsSegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelOf,
    this.size = TdsSegmentedSize.l,
    this.fullWidth = true,
  });

  final List<T> items;
  final T value;
  final ValueChanged<T> onChanged;

  /// 항목을 화면에 보일 문자열로 바꾸는 함수.
  final String Function(T) labelOf;

  final TdsSegmentedSize size;

  /// true면 항목이 트랙을 균등하게 나눠 갖는다.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final (height, radius, fontSize) = switch (size) {
      TdsSegmentedSize.s => (TdsSize.segmentedS, TdsRadius.segmentedS, 13.0),
      TdsSegmentedSize.l => (TdsSize.segmentedL, TdsRadius.segmentedL, 15.0),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TdsSpacing.pageMarginM),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
        decoration: BoxDecoration(
          color: TdsColors.fillNeutralWeak,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (final item in items)
              if (fullWidth)
                Expanded(child: _segment(item, radius, fontSize))
              else
                _segment(item, radius, fontSize),
          ],
        ),
      ),
    );
  }

  Widget _segment(T item, double radius, double fontSize) {
    final selected = item == value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selected ? null : () => onChanged(item),
      child: AnimatedContainer(
        duration: TdsMotion.fast,
        curve: TdsMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? TdsColors.background : null,
          borderRadius: BorderRadius.circular(radius - 4),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14001B37),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          labelOf(item),
          maxLines: 1,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.35,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color:
                selected ? TdsColors.textPrimary : TdsColors.textQuaternary,
          ),
        ),
      ),
    );
  }
}
