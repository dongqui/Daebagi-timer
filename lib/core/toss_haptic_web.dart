import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';

/// `web/js/apps_in_toss.js`가 노출하는 전역 (`AppsInTossModule`).
@JS('AppsInTossModule')
external _AppsInTossModule? get _appsInTossModule;

@JS('ReactNativeWebView')
external JSObject? get _reactNativeWebView;

@JS('navigator')
external JSObject? get _navigator;

extension type _AppsInTossModule(JSObject _) implements JSObject {
  @JS('Device')
  external _Device? get device;
}

extension type _Device(JSObject _) implements JSObject {
  external JSPromise<JSAny?> triggerHaptic(JSObject options);
}

/// SDK에 넘길 햅틱 타입.
///
/// 길이를 못 받으니 짧은 걸 여러 번 이어 붙인다. 그래서 `error`·`success`처럼
/// 그 자체가 두세 박자짜리 알림 패턴인 타입은 안 맞는다 — 겹쳐 울리면 서로
/// 먹혀서 오히려 끊긴 느낌이 난다. 한 박자짜리 임팩트를 쓴다.
///
/// 실기기에서 비교해 볼 만한 대안: `basicWeak`(더 약함), `tickMedium`(더 짧고
/// 날카로움). `wiggle`·`confetti`는 그 자체로 긴 패턴일 수 있어서, 만약
/// 그렇다면 반복 없이 한 번만 불러도 원하는 그림이 나온다.
const _hapticType = 'basicMedium';

/// 이어 붙이는 간격. 짧을수록 하나의 긴 진동처럼 느껴지지만, 너무 촘촘하면
/// 브릿지 호출이 밀려 오히려 불규칙해진다.
const _pulseInterval = Duration(milliseconds: 130);

/// [duration] 동안 이어지는 알림 진동.
///
/// 토스 웹뷰 안에서는 SDK가 네이티브 햅틱을 대신 울려준다. 다만 SDK는 길이를
/// 못 받으므로([_hapticType]), 짧은 진동을 [_pulseInterval] 간격으로 이어
/// 붙여 [duration]을 채운다.
///
/// 웹뷰가 아닌 일반 브라우저에서는 `navigator.vibrate`가 길이를 그대로 받아
/// 진짜 한 번의 긴 진동이 된다 — 안드로이드 크롬 등. iOS 사파리는 이 API가
/// 아예 없어서 아무 일도 일어나지 않는다.
Future<void> playAlertHaptic(Duration duration) async {
  final device = _appsInTossModule?.device;
  if (_reactNativeWebView != null && device != null) {
    await _repeatSdkHaptic(device, duration);
    return;
  }

  try {
    final navigator = _navigator;
    if (navigator == null || !navigator.has('vibrate')) return;
    navigator.callMethod<JSAny?>('vibrate'.toJS, duration.inMilliseconds.toJS);
  } catch (e) {
    debugPrint('브라우저 진동 실패 (무시): $e');
  }
}

Future<void> _repeatSdkHaptic(_Device device, Duration duration) async {
  final options = JSObject()..['type'] = _hapticType.toJS;
  final elapsed = Stopwatch()..start();

  while (elapsed.elapsed < duration) {
    try {
      await device.triggerHaptic(options).toDart;
    } catch (e) {
      // 한 번 실패하면 다음도 실패한다. 브릿지를 계속 두드릴 이유가 없다.
      debugPrint('앱인토스 햅틱 실패 (무시): $e');
      return;
    }

    final remaining = duration - elapsed.elapsed;
    if (remaining <= Duration.zero) return;
    await Future<void>.delayed(
      remaining < _pulseInterval ? remaining : _pulseInterval,
    );
  }
}
