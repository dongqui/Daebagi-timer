import 'package:flutter/widgets.dart';

import 'toss_safe_area_stub.dart'
    if (dart.library.js_interop) 'toss_safe_area_web.dart';

/// 앱인토스가 알려주는 안전 영역을 [MediaQuery]에 심어주는 래퍼.
///
/// Flutter Web은 웹뷰 안에서 `MediaQuery.padding`을 0으로 보고한다. 그대로 두면
/// 상단 아이콘과 텍스트가 상태바를 뚫고 올라가고, 하단은 홈 인디케이터에 물린다.
///
/// 화면들이 전부 `MediaQuery.paddingOf(context)`를 보고 여백을 잡으므로,
/// 앱 최상단에서 한 번만 바꿔주면 전체가 따라온다.
class TossSafeArea extends StatelessWidget {
  const TossSafeArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final insets = tossSafeAreaInsets();
    if (insets == null) return child;

    final media = MediaQuery.of(context);
    return MediaQuery(
      // viewPadding도 같이 맞춘다. 키보드가 올라오면 padding.bottom은 0이 되지만
      // viewPadding은 유지되는데, 둘이 어긋나면 계산이 꼬인다.
      data: media.copyWith(padding: insets, viewPadding: insets),
      child: child,
    );
  }
}
