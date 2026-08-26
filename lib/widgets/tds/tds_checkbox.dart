import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_typography.dart';

enum TdsCheckboxSize { xs, s, m, l }

/// TDS 체크박스의 `circle` 변형.
///
/// 켜지면 브랜드색 원, 꺼지면 옅은 회색 원에 흐린 체크가 남는다 —
/// 빈 네모가 아니라 항상 체크 모양이 보이는 게 TDS 방식이다.
class TdsCheckbox extends StatelessWidget {
  const TdsCheckbox({
    super.key,
    required this.checked,
    this.onChanged,
    this.label,
    this.size = TdsCheckboxSize.m,
  });

  final bool checked;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final TdsCheckboxSize size;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final dimension = switch (size) {
      TdsCheckboxSize.xs => 16.0,
      TdsCheckboxSize.s => 20.0,
      TdsCheckboxSize.m => 24.0,
      TdsCheckboxSize.l => 28.0,
    };
    final on = checked && enabled;

    final box = Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: on ? TdsColors.brand : TdsColors.fillNeutralWeak,
        ),
        child: Icon(
          Icons.check_rounded,
          size: dimension * 0.66,
          color: on ? TdsColors.textOnFill : TdsColors.iconQuaternary,
        ),
      ),
    );

    return Semantics(
      checked: checked,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!checked) : null,
        child: label == null
            ? box
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  box,
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label!,
                      style: TdsText.bodyMedium.copyWith(
                        color: TdsColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
