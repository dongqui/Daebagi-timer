import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

enum TdsNumericSpinnerSize { xs, s, m, l }

/// 수량 선택기. 집중 시간의 시/분/초를 고르는 데 쓴다.
///
/// 좌우 버튼으로 하나씩 조절하거나, 가운데 숫자를 눌러 직접 입력할 수 있다.
/// 숫자 칸은 TDS에서 유일하게 1px 리프트 섀도를 쓰는 자리다.
class TdsNumericSpinner extends StatefulWidget {
  const TdsNumericSpinner({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.size = TdsNumericSpinnerSize.m,
    this.enabled = true,
    this.semanticLabel,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final TdsNumericSpinnerSize size;
  final bool enabled;

  /// 직접 입력할 때 어떤 값인지 알려주는 이름 (예: '분').
  final String? semanticLabel;

  @override
  State<TdsNumericSpinner> createState() => _TdsNumericSpinnerState();
}

class _TdsNumericSpinnerState extends State<TdsNumericSpinner> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    // 다른 곳을 누르면 입력 중이던 값을 확정한다.
    if (!_focusNode.hasFocus && _editing) _commit();
  }

  void _startEditing() {
    if (!widget.enabled) return;
    _controller.text = '${widget.value}';
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    setState(() => _editing = true);
    _focusNode.requestFocus();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    setState(() => _editing = false);

    // 빈 칸이나 이상한 값이면 원래 값을 유지한다.
    if (parsed == null) return;
    widget.onChanged(parsed.clamp(widget.min, widget.max));
  }

  void _step(int delta) => widget.onChanged(
        (widget.value + delta).clamp(widget.min, widget.max),
      );

  @override
  Widget build(BuildContext context) {
    final (height, buttonSize, radius, fontSize) = switch (widget.size) {
      TdsNumericSpinnerSize.xs => (
          TdsSize.numericSpinnerXs,
          TdsSize.numericSpinnerXsButton,
          10.0,
          13.0,
        ),
      TdsNumericSpinnerSize.s => (42.0, 30.0, 12.0, 15.0),
      TdsNumericSpinnerSize.m => (50.0, 36.0, 14.0, 17.0),
      TdsNumericSpinnerSize.l => (58.0, 44.0, 16.0, 20.0),
    };

    final numberStyle = TextStyle(
      fontSize: fontSize,
      height: 1,
      fontWeight: FontWeight.w600,
      color: TdsColors.numericSpinnerFieldText,
    );

    return Opacity(
      opacity: widget.enabled ? 1 : 0.4,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        decoration: BoxDecoration(
          color: TdsColors.fillNeutralWeak,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              size: buttonSize,
              plus: false,
              enabled: widget.enabled && widget.value > widget.min,
              onTap: () => _step(-1),
            ),
            _NumberField(
              radius: radius,
              editing: _editing,
              style: numberStyle,
              value: widget.value,
              controller: _controller,
              focusNode: _focusNode,
              semanticLabel: widget.semanticLabel,
              onTap: _startEditing,
              onSubmitted: (_) => _commit(),
            ),
            _StepButton(
              size: buttonSize,
              plus: true,
              enabled: widget.enabled && widget.value < widget.max,
              onTap: () => _step(1),
            ),
          ],
        ),
      ),
    );
  }
}

/// 가운데 숫자 칸. 평소에는 텍스트, 누르면 입력 필드가 된다.
class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.radius,
    required this.editing,
    required this.style,
    required this.value,
    required this.controller,
    required this.focusNode,
    required this.semanticLabel,
    required this.onTap,
    required this.onSubmitted,
  });

  final double radius;
  final bool editing;
  final TextStyle style;
  final int value;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? semanticLabel;
  final VoidCallback onTap;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: editing ? null : onTap,
      child: Semantics(
        label: semanticLabel == null ? '직접 입력' : '$semanticLabel 직접 입력',
        child: Container(
          constraints: const BoxConstraints(minWidth: 49),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TdsColors.numericSpinnerFieldFill,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A001B37),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          // 스피너는 Row(mainAxisSize.min) 안이라 폭이 무한대로 열려 있다.
          // TextField는 폭이 정해져 있어야 해서 숫자 칸 크기로 못박는다.
          child: editing
              ? SizedBox(
                  width: 45,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 2,
                    style: style,
                    cursorColor: TdsColors.textOnFill,
                    cursorHeight: style.fontSize,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      counterText: '',
                    ),
                    onSubmitted: onSubmitted,
                  ),
                )
              : Text('$value', style: style),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.size,
    required this.plus,
    required this.enabled,
    required this.onTap,
  });

  final double size;
  final bool plus;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Semantics(
        button: true,
        label: plus ? '증가' : '감소',
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: CustomPaint(
              size: const Size.square(16),
              painter: _StepIconPainter(
                plus: plus,
                color:
                    enabled ? TdsColors.iconTertiary : TdsColors.iconQuaternary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIconPainter extends CustomPainter {
  const _StepIconPainter({required this.plus, required this.color});

  final bool plus;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final mid = size.width / 2;
    const inset = 3.0;
    canvas.drawLine(
      Offset(inset, mid),
      Offset(size.width - inset, mid),
      paint,
    );
    if (plus) {
      canvas.drawLine(
        Offset(mid, inset),
        Offset(mid, size.height - inset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StepIconPainter oldDelegate) =>
      oldDelegate.plus != plus || oldDelegate.color != color;
}
