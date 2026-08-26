import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

enum TdsIconButtonSize { s, m, l }

enum TdsIconButtonVariant { fill, border, clear }

/// 아이콘 하나짜리 액션. 히트 영역은 크기별로 32 / 38 / 44px 고정이다.
class TdsIconButton extends StatefulWidget {
  const TdsIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = TdsIconButtonSize.m,
    this.variant = TdsIconButtonVariant.fill,
    this.color = TdsColors.iconPrimary,
    this.semanticLabel,
  });

  /// 아이콘 위젯. 크기는 이 위젯이 정한 박스에 맞춰 넘길 것.
  final Widget icon;

  final VoidCallback? onPressed;
  final TdsIconButtonSize size;
  final TdsIconButtonVariant variant;
  final Color color;
  final String? semanticLabel;

  @override
  State<TdsIconButton> createState() => _TdsIconButtonState();
}

class _TdsIconButtonState extends State<TdsIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final (box, radius, iconSize) = switch (widget.size) {
      TdsIconButtonSize.s => (32.0, 11.0, 18.0),
      TdsIconButtonSize.m => (TdsSize.iconButtonM, TdsRadius.iconButton, 20.0),
      TdsIconButtonSize.l => (TdsSize.iconButtonL, 15.0, 24.0),
    };

    final button = Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: box,
          height: box,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.variant == TdsIconButtonVariant.fill
                ? TdsColors.fillNeutralWeak
                : null,
            borderRadius: BorderRadius.circular(radius),
            border: widget.variant == TdsIconButtonVariant.border
                ? Border.all(color: TdsColors.border, width: 1)
                : null,
          ),
          child: SizedBox.square(
            dimension: iconSize,
            child: IconTheme.merge(
              data: IconThemeData(color: widget.color, size: iconSize),
              child: Center(child: widget.icon),
            ),
          ),
        ),
        if (_pressed)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: TdsColors.fillPressed,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: button,
      ),
    );
  }
}
