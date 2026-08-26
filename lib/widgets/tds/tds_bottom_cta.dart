import 'package:flutter/widgets.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';

/// 화면 맨 아래 붙는 주 액션 영역.
///
/// 홈 인디케이터를 피하도록 하단 안전 영역만큼 자동으로 더 띄운다.
class TdsBottomCta extends StatelessWidget {
  const TdsBottomCta({
    super.key,
    required this.child,
    this.upperItem,
    this.lowerItem,
    this.gradient = true,
  });

  /// 주 버튼. 보통 `TdsButton(size: xl, fullWidth: true)`.
  final Widget child;

  /// 버튼 위 보조 정보(약관, 합계 등).
  final Widget? upperItem;

  /// 버튼 아래 보조 액션. 보통 [TdsTextButton].
  final Widget? lowerItem;

  /// 스크롤되는 내용이 버튼 뒤로 사라질 때 위쪽에 페이드를 깐다.
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (gradient)
          Container(
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x0017171C), TdsColors.background],
              ),
            ),
          ),
        Container(
          width: double.infinity,
          color: TdsColors.background,
          padding: EdgeInsets.only(
            bottom: 20 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (upperItem != null)
                Container(
                  constraints: const BoxConstraints(minHeight: 50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: TdsSpacing.pageMarginS,
                  ),
                  alignment: Alignment.center,
                  child: upperItem,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TdsSpacing.pageMarginS,
                ),
                child: child,
              ),
              if (lowerItem != null)
                Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  child: lowerItem,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
