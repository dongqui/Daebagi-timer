import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// `web/index.html`이 로드하는 SDK 번들의 전역
/// (`esbuild --global-name=AppsInTossModule`, `toss/apps_in_toss_entry.js` 참조).
@JS('AppsInTossModule')
external _AppsInTossModule? get _appsInTossModule;

/// 토스 앱 웹뷰가 주입하는 브릿지. SDK 자체가 이 값의 존재로 웹뷰 여부를
/// 판별하며, 일반 브라우저에는 없다.
@JS('ReactNativeWebView')
external JSObject? get _reactNativeWebView;

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

/// 토스 네비게이션 바(더보기·닫기 버튼 줄)가 차지하는 높이.
///
/// `apps-in-toss.config.ts`에서 `transparentBackground: true`로 두면 네비게이션
/// 바가 웹뷰 위에 겹쳐 뜬다. 배경이 끊기지 않아 별밭이 화면 끝까지 이어지는
/// 대신, 그 아래로 콘텐츠가 파고들지 않도록 이 높이를 우리가 비워야 한다.
///
/// SDK는 상태바 높이(`SafeArea.get().top`)까지만 알려주고 네비게이션 바 높이는
/// 알려주지 않아서 상수로 둔다. 토스 네비게이션 바는 TDS 기본값과 같은 56이다.
/// 조금 어긋나도 여백이 아쉽거나 넉넉해질 뿐, 불투명 배경일 때처럼 경계선이
/// 생기지는 않는다.
const double kTossNavigationBarHeight = 56;

/// 앱인토스 환경에서 콘텐츠가 피해야 하는 여백.
///
/// Flutter Web은 웹뷰 안에서 `MediaQuery.padding`을 0으로 보고한다. 상태바나
/// 홈 인디케이터를 브라우저 뷰포트가 알려주지 않기 때문이다. 그대로 두면 상단
/// 아이콘과 텍스트가 상태바를 뚫고 올라간다. SDK가 주는 값을 대신 쓴다.
///
/// 토스 웹뷰가 아니면 `null`을 돌려준다 — 그때는 브라우저가 주는 값
/// (iOS 사파리의 노치 여백 등)이 이미 정확하다.
EdgeInsets? tossSafeAreaInsets() {
  // 일반 브라우저에서도 SDK 번들은 로드되므로, 모듈 존재 여부로는 웹뷰인지
  // 알 수 없다. 브릿지가 있는지로 판별한다.
  if (_reactNativeWebView == null) return null;

  try {
    final insets = _appsInTossModule?.safeArea?.get();
    // 웹뷰인 건 확실하니 insets를 못 읽어도 네비게이션 바만큼은 비운다.
    if (insets == null) {
      return const EdgeInsets.only(top: kTossNavigationBarHeight);
    }

    return EdgeInsets.fromLTRB(
      insets.left,
      insets.top + kTossNavigationBarHeight,
      insets.right,
      insets.bottom,
    );
  } catch (e) {
    debugPrint('앱인토스 Safe Area 조회 실패 (네비게이션 바 높이만 적용): $e');
    return const EdgeInsets.only(top: kTossNavigationBarHeight);
  }
}
