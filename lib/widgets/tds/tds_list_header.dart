import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';

enum TdsListHeaderPadding { s, m, l }

/// 리스트 위에 붙는 섹션 제목.
class TdsListHeader extends StatelessWidget {
  const TdsListHeader({
    super.key,
    required this.title,
    this.description,
    this.verticalPadding = TdsListHeaderPadding.m,
  });

  final String title;
  final String? description;
  final TdsListHeaderPadding verticalPadding;

  @override
  Widget build(BuildContext context) {
    final padY = switch (verticalPadding) {
      TdsListHeaderPadding.s => 12.0,
      TdsListHeaderPadding.m => 16.0,
      TdsListHeaderPadding.l => 20.0,
    };

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: padY,
        horizontal: TdsSpacing.pageMarginM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TdsText.subtitle),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TdsText.body.copyWith(color: TdsColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}
