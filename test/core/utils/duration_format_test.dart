import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/core/utils/duration_format.dart';

void main() {
  group('formatHumanDuration', () {
    test('1분 미만은 초만 보여준다', () {
      expect(formatHumanDuration(0), '0초');
      expect(formatHumanDuration(59), '59초');
    });

    test('1시간 미만은 분과 초', () {
      expect(formatHumanDuration(60), '1분');
      expect(formatHumanDuration(90), '1분 30초');
      expect(formatHumanDuration(1500), '25분');
      expect(formatHumanDuration(3599), '59분 59초');
    });

    test('1시간이 넘어도 초를 버리지 않는다', () {
      // 3시간 31분 59초를 골랐는데 '3시간 31분'으로 보이면 안 된다.
      expect(formatHumanDuration(12719), '3시간 31분 59초');
      expect(formatHumanDuration(5445), '1시간 30분 45초');
    });

    test('0인 단위는 건너뛴다', () {
      expect(formatHumanDuration(3600), '1시간');
      expect(formatHumanDuration(3660), '1시간 1분');
      expect(formatHumanDuration(3601), '1시간 1초');
      expect(formatHumanDuration(3661), '1시간 1분 1초');
    });
  });

  group('formatTimerClock', () {
    test('1시간 미만은 MM:SS', () {
      expect(formatTimerClock(0), '00:00');
      expect(formatTimerClock(65), '01:05');
      expect(formatTimerClock(3599), '59:59');
    });

    test('1시간 이상은 H:MM:SS', () {
      expect(formatTimerClock(3600), '1:00:00');
      expect(formatTimerClock(3725), '1:02:05');
    });
  });

  group('formatTimeOfDay', () {
    test('오전과 오후를 나눈다', () {
      expect(formatTimeOfDay(DateTime(2026, 8, 26, 9, 5)), '오전 9:05');
      expect(formatTimeOfDay(DateTime(2026, 8, 26, 15, 24)), '오후 3:24');
    });

    test('자정과 정오는 12시로 읽는다', () {
      expect(formatTimeOfDay(DateTime(2026, 8, 26, 0, 0)), '오전 12:00');
      expect(formatTimeOfDay(DateTime(2026, 8, 26, 12, 30)), '오후 12:30');
    });
  });
}
