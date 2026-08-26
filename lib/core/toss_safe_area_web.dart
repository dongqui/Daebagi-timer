import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// `web/index.html`이 로드하는 SDK 번들의 전역
/// (`esbuild --global-name=AppsInTossModule`, `toss/apps_in_toss_entry.js` 참조).
@JS('AppsInTossModule')
external _AppsInTossModule? get _appsInTossModule;

extension type _AppsInTossModule(JSObject _) implements JSObject {
  @JS('SafeArea')
  external _SafeArea? get safeArea;
}

extension type _SafeArea(JSObject _) implements JSObject {
  /// 호스트가 콘텐츠 로드 전에 주입한 값이라 동기로 읽을 수 있다.
  external _Insets get();
}

extension type _Insets(JSObject _) implements JSObject {
  external double get top;
  external double get bottom;
  external double get left;
  external double get right;
}

/// 앱인토스가 알려주는 안전 영역.
///
/// Flutter Web은 웹뷰 안에서 `MediaQuery.padding`을 0으로 보고한다. 상태바나
/// 홈 인디케이터를 브라우저 뷰포트가 알려주지 않기 때문이다. 그대로 두면 상단
/// 아이콘과 텍스트가 상태바를 뚫고 올라간다. SDK가 주는 값을 대신 쓴다.
///
/// 토스 웹뷰가 아니거나 SDK를 못 찾으면 `null`을 돌려준다 — 그때는 브라우저가
/// 주는 값을 그대로 쓰는 게 맞다.
EdgeInsets? tossSafeAreaInsets() {
  try {
    final insets = _appsInTossModule?.safeArea?.get();
    if (insets == null) return null;

    final result = EdgeInsets.fromLTRB(
      insets.left,
      insets.top,
      insets.right,
      insets.bottom,
    );
    // 토스 웹뷰 밖에서는 SDK가 0을 돌려준다. 그때는 브라우저가 이미 아는 값
    // (iOS 사파리의 노치 여백 등)을 덮어쓰지 않도록 손대지 않는다.
    return result == EdgeInsets.zero ? null : result;
  } catch (e) {
    debugPrint('앱인토스 Safe Area 조회 실패 (무시): $e');
    return null;
  }
}
