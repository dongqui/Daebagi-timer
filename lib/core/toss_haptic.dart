/// [duration] 동안 이어지는 알림 진동.
///
/// 웹(앱인토스) 빌드에서는 토스 SDK의 햅틱을, 네이티브에서는 OS 진동을 쓴다.
/// 어느 쪽도 안 되는 환경(진동 없는 기기, 일반 데스크톱 브라우저, iOS 사파리)
/// 에서는 조용히 넘어간다 — 진동은 거들 뿐이라 실패가 흐름을 막으면 안 된다.
///
/// "한 번의 긴 진동"을 그대로 낼 수 있는 건 `navigator.vibrate`를 쓰는 일반
/// 브라우저뿐이다. 앱인토스 SDK와 Flutter `HapticFeedback`은 둘 다 길이를
/// 못 받으므로, 짧은 진동을 촘촘히 이어 붙여 비슷하게 흉내낸다.
library;

export 'toss_haptic_stub.dart'
    if (dart.library.js_interop) 'toss_haptic_web.dart';
