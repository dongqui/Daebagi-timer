import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

/// TDS 구분선.
///
/// `thin`은 1px 헤어라인, `thick`은 섹션을 가르는 16px 띠다. 두꺼운 쪽은 선이
/// 아니라 배경보다 어두운 면으로 그려진다 — 그래서 색이 [TdsColors.borderThick].
class TdsBorder extends StatelessWidget {
  const TdsBorder({super.key, this.thick = false});

  const TdsBorder.thick({super.key}) : thick = true;

  final bool thick;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thick ? TdsSize.borderThick : TdsSize.borderThin,
      color: thick ? TdsColors.borderThick : TdsColors.border,
    );
  }
}
