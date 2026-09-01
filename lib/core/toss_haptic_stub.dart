import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 이어 붙이는 간격. `toss_haptic_web.dart`와 같은 이유로 촘촘히 준다.
const _pulseInterval = Duration(milliseconds: 130);

/// [duration] 동안 이어지는 알림 진동.
///
/// 네이티브 빌드는 토스 웹뷰 안에서 돌지 않는다. OS 진동을 직접 부른다.
/// `heavyImpact`(툭 치는 느낌)가 아니라 `vibrate`(시스템 진동)를 쓴다 —
/// 임팩트 계열은 화면을 보고 있을 때 쓰는 짧은 촉감이라, 폰을 엎어둔 사람에게
/// 알리기엔 약하다.
///
/// Flutter의 [HapticFeedback]도 길이를 못 받으므로 짧은 진동을 이어 붙인다.
/// 진짜 한 번의 긴 진동이 필요하면 `Vibrator.vibrate(2000)`을 부르는 플랫폼
/// 채널이나 진동 플러그인이 있어야 한다.
Future<void> playAlertHaptic(Duration duration) async {
  final elapsed = Stopwatch()..start();

  while (elapsed.elapsed < duration) {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('진동 실패 (무시): $e');
      return;
    }

    final remaining = duration - elapsed.elapsed;
    if (remaining <= Duration.zero) return;
    await Future<void>.delayed(
      remaining < _pulseInterval ? remaining : _pulseInterval,
    );
  }
}
