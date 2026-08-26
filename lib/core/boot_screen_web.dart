import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// `web/index.html`이 정의하는 전역. 부트 화면을 페이드아웃 후 제거한다.
@JS('hideBootScreen')
external void _hideBootScreen();

/// 부팅 중 보여주던 검은 화면을 걷어낸다.
///
/// Flutter가 첫 프레임을 그린 뒤에 불러야 한다. 그 전에 걷으면 엔진이 아직
/// 아무것도 안 그린 순간이 드러나 흰 화면이 깜빡인다.
///
/// index.html이 예전 버전이면 전역이 없을 수 있다. 부트 화면이 조금 늦게
/// 사라지는 것보다 앱이 죽는 게 훨씬 나쁘므로 실패는 삼킨다.
void hideBootScreen() {
  try {
    _hideBootScreen();
  } catch (e) {
    debugPrint('부트 화면 제거 실패 (무시): $e');
  }
}
