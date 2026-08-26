import 'package:flutter/material.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

/// TDS 텍스트 입력의 `box` 변형.
///
/// 시트나 색이 있는 표면 위에 놓일 때 쓰는 형태다. 포커스가 가면 채움이
/// 파랗게 물들고 1px 링이 생긴다.
class TdsTextField extends StatefulWidget {
  const TdsTextField({
    super.key,
    this.controller,
    this.label,
    this.labelStyle,
    this.placeholder,
    this.helpText,
    this.error = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.maxLength,
  });

  final TextEditingController? controller;
  final String? label;

  /// 라벨 스타일. 기본은 TDS의 13px 보조 라벨이다. 같은 시트 안에서
  /// `TdsListHeader`와 나란히 놓일 때는 `TdsText.subtitle`로 맞춘다.
  final TextStyle? labelStyle;

  final String? placeholder;
  final String? helpText;
  final bool error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final int? maxLength;

  @override
  State<TdsTextField> createState() => _TdsTextFieldState();
}

class _TdsTextFieldState extends State<TdsTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

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
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringVisible = _focused || widget.error;
    final ringColor = widget.error
        ? TdsColors.textFieldBorderError
        : TdsColors.textFieldBorderFocused;

    final fill = widget.error
        ? const Color(0x1CD3665C)
        : _focused
            ? TdsColors.textFieldBoxFillFocused
            : TdsColors.textFieldBoxFill;

    return Container(
      width: double.infinity,
      color: TdsColors.background,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: TdsSpacing.pageMarginM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: widget.labelStyle ??
                  const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: TdsColors.textPrimary,
                  ),
            ),
            const SizedBox(height: TdsSpacing.gapS),
          ],
          AnimatedContainer(
            duration: TdsMotion.fast,
            curve: TdsMotion.standard,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(TdsRadius.textField),
              border: Border.all(
                color: ringVisible ? ringColor : const Color(0x00000000),
                width: 1,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: widget.textInputAction,
              maxLength: widget.maxLength,
              maxLines: 1,
              cursorColor: TdsColors.brand,
              style: const TextStyle(
                fontSize: 17,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: TdsColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                counterText: '',
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  fontSize: 17,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: TdsColors.textQuaternary,
                ),
              ),
            ),
          ),
          if (widget.helpText != null) ...[
            const SizedBox(height: TdsSpacing.gapS),
            Text(
              widget.helpText!,
              style: TextStyle(
                fontSize: 13,
                height: 19.5 / 13,
                color: widget.error
                    ? TdsColors.danger
                    : TdsColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
