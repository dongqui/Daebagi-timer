import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// `web/index.html`이 정의하는 전역. 부트 화면을 페이드아웃 후 제거한다.
@JS('hideBootScreen')
external void _hideBootScreen();

@JS('performance')
external _Performance get _performance;

extension type _Performance(JSObject _) implements JSObject {
  /// 페이지를 열기 시작한 시점부터 흐른 밀리초.
  external double now();
}

/// 브라우저가 페이지를 열기 시작한 뒤로 흐른 시간.
///
/// 인트로는 Dart가 뜨기 한참 전, 부트 화면이 그려지는 순간부터 시작된다.
/// 전체 길이를 이 시점 기준으로 재야 부팅이 빠르든 느리든 같은 리듬이 된다.
Duration bootElapsed() {
  try {
    return Duration(milliseconds: _performance.now().round());
  } catch (e) {
    debugPrint('부팅 경과 시간 조회 실패 (무시): $e');
    return Duration.zero;
  }
}

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
