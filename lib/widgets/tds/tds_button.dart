import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

enum TdsButtonSize { s, m, l, xl }

enum TdsButtonColor { brand, danger, neutral, primaryInverse }

enum TdsButtonVariant { fill, weak }

/// TDS 기본 버튼. 화면에서 가장 하고 싶은 동작 하나에 쓴다.
///
/// 비활성은 전체 불투명도 30%, 눌림은 검정 26% 오버레이다 — 색을 바꾸지 않는다.
class TdsButton extends StatefulWidget {
  const TdsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = TdsButtonSize.l,
    this.color = TdsButtonColor.brand,
    this.variant = TdsButtonVariant.fill,
    this.fullWidth = false,
  });

  final String label;

  /// null이면 비활성으로 그린다.
  final VoidCallback? onPressed;

  final TdsButtonSize size;
  final TdsButtonColor color;
  final TdsButtonVariant variant;
  final bool fullWidth;

  @override
  State<TdsButton> createState() => _TdsButtonState();
}

class _TdsButtonState extends State<TdsButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final metrics = _TdsButtonMetrics.of(widget.size);
    final weak = widget.variant == TdsButtonVariant.weak;
    final palette = _TdsButtonPalette.of(widget.color);

    final button = Opacity(
      opacity: enabled ? 1 : 0.3,
      child: Stack(
        children: [
          Container(
            height: metrics.height,
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: metrics.paddingX),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: weak ? palette.weakFill : palette.fill,
              borderRadius: BorderRadius.circular(metrics.radius),
            ),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: metrics.fontSize,
                height: 1,
                fontWeight: FontWeight.w600,
                color: weak ? palette.weakOn : palette.on,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _pressed ? 0.26 : 0,
                duration: TdsMotion.fast,
                curve: TdsMotion.standard,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    borderRadius: BorderRadius.circular(metrics.radius),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: widget.fullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

class _TdsButtonMetrics {
  const _TdsButtonMetrics(
    this.height,
    this.radius,
    this.paddingX,
    this.fontSize,
  );

  final double height;
  final double radius;
  final double paddingX;
  final double fontSize;

  static _TdsButtonMetrics of(TdsButtonSize size) => switch (size) {
        TdsButtonSize.s =>
          const _TdsButtonMetrics(TdsSize.buttonS, TdsRadius.buttonS, 10, 13),
        TdsButtonSize.m =>
          const _TdsButtonMetrics(TdsSize.buttonM, TdsRadius.buttonM, 16, 15),
        TdsButtonSize.l =>
          const _TdsButtonMetrics(TdsSize.buttonL, TdsRadius.buttonL, 16, 17),
        TdsButtonSize.xl =>
          const _TdsButtonMetrics(TdsSize.buttonXL, TdsRadius.buttonXL, 28, 17),
      };
}

class _TdsButtonPalette {
  const _TdsButtonPalette(this.fill, this.on, this.weakFill, this.weakOn);

  final Color fill;
  final Color on;
  final Color weakFill;
  final Color weakOn;

  static _TdsButtonPalette of(TdsButtonColor color) => switch (color) {
        TdsButtonColor.brand => const _TdsButtonPalette(
            TdsColors.brand,
            TdsColors.textOnFill,
            TdsColors.brandWeak,
            TdsColors.brandWeakText,
          ),
        TdsButtonColor.danger => const _TdsButtonPalette(
            TdsColors.danger,
            TdsColors.textOnFill,
            TdsColors.dangerWeak,
            TdsColors.dangerWeakText,
          ),
        TdsButtonColor.neutral => const _TdsButtonPalette(
            TdsColors.fillNeutral,
            TdsColors.textOnFill,
            TdsColors.fillNeutralWeak,
            TdsColors.textSecondary,
          ),
        TdsButtonColor.primaryInverse => const _TdsButtonPalette(
            TdsColors.fillInverse,
            TdsColors.textPrimary,
            TdsColors.fillInverseWeak,
            TdsColors.textStrong,
          ),
      };
}
