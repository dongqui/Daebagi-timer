import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// `web/index.html`이 정의하는 전역. 인트로를 페이드아웃 후 제거한다.
@JS('hideBootScreen')
external void _hideBootScreen();

/// 부팅 중 화면을 덮고 있던 인트로를 걷어낸다.
///
/// 홈이 실제로 그려진 뒤에 불러야 한다. 그 전에 걷으면 아직 아무것도 없는
/// 화면이 드러난다. 최소 노출 시간은 `index.html` 쪽에서 지킨다.
///
/// index.html이 예전 버전이면 전역이 없을 수 있다. 인트로가 조금 늦게 사라지는
/// 것보다 앱이 죽는 게 훨씬 나쁘므로 실패는 삼킨다.
void hideBootScreen() {
  try {
    _hideBootScreen();
  } catch (e) {
    debugPrint('인트로 제거 실패 (무시): $e');
  }
}
