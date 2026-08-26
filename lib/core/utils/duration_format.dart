/// 집중 시간·시각을 화면용 문자열로 바꾸는 함수 모음.
///
/// 완료·기록 화면과 타이머가 같은 규칙을 쓰도록 한곳에 모아둔다.
library;

/// 사람이 읽는 길이. `90` → `1분 30초`, `12719` → `3시간 31분 59초`.
///
/// 0인 단위는 건너뛰고 남은 단위만 이어 붙인다. 고른 시간과 화면에 뜨는 값이
/// 어긋나면 안 되므로 초도 버리지 않는다.
String formatHumanDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds ~/ 60) % 60;
  final remainingSeconds = seconds % 60;

  final parts = [
    if (hours > 0) '$hours시간',
    if (minutes > 0) '$minutes분',
    if (remainingSeconds > 0) '$remainingSeconds초',
  ];

  return parts.isEmpty ? '0초' : parts.join(' ');
}

/// 타이머에 띄우는 경과 시간. 1시간 미만이면 `MM:SS`, 넘으면 `H:MM:SS`.
String formatTimerClock(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds ~/ 60) % 60;
  final remainingSeconds = seconds % 60;

  final mmss = '${_pad(minutes)}:${_pad(remainingSeconds)}';
  return hours > 0 ? '$hours:$mmss' : mmss;
}

/// `오후 3:24` 형식의 시각.
String formatTimeOfDay(DateTime time) {
  final hour = time.hour;
  final period = hour < 12 ? '오전' : '오후';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$period $displayHour:${_pad(time.minute)}';
}

String _pad(int value) => value.toString().padLeft(2, '0');
