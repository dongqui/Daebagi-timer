import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

/// TDS 리스트 행 — 제목 왼쪽, 값 오른쪽.
///
/// 완료·기록 화면에서 요약 값을 늘어놓는 데 쓴다.
class TdsListRow extends StatefulWidget {
  const TdsListRow({
    super.key,
    required this.title,
    this.description,
    this.right,
    this.onTap,
    this.strongTitle = false,
  });

  final String title;
  final String? description;

  /// 오른쪽에 붙는 값. 문자열이면 [TdsListRow.value]를 쓰는 게 편하다.
  final Widget? right;

  final VoidCallback? onTap;
  final bool strongTitle;

  /// 오른쪽 값이 그냥 텍스트일 때의 표준 스타일.
  static Widget value(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          height: 25.5 / 17,
          fontWeight: FontWeight.w500,
          color: TdsColors.textPrimary,
        ),
      );

  @override
  State<TdsListRow> createState() => _TdsListRowState();
}

class _TdsListRowState extends State<TdsListRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final clickable = widget.onTap != null;

    final row = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44),
      color: TdsColors.background,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: TdsSpacing.listRowPaddingX,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    height: 25.5 / 17,
                    fontWeight:
                        widget.strongTitle ? FontWeight.w700 : FontWeight.w500,
                    color: TdsColors.textPrimary,
                  ),
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 22.5 / 15,
                      color: TdsColors.textQuaternary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.right != null) ...[
            const SizedBox(width: 12),
            widget.right!,
          ],
        ],
      ),
    );

    if (!clickable) return row;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Stack(
        children: [
          row,
          if (_pressed)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: TdsColors.fillPressed),
              ),
            ),
        ],
      ),
    );
  }
}
