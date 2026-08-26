import 'package:catodo/features/presentation/viewmodels/chart_state.dart';

class DateHelper {
  /// 하루의 시작 시간 구하기 (00:00:00)
  static DateTime getDayStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 하루의 끝 시간 구하기 (23:59:59)
  static DateTime getDayEnd(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// 주의 시작일 구하기 (월요일)
  static DateTime getWeekStart(DateTime date) {
    // 월요일이 1, 일요일이 7
    final difference = date.weekday - 1;
    return getDayStart(date.subtract(Duration(days: difference)));
  }

  /// 주의 마지막일 구하기 (일요일)
  static DateTime getWeekEnd(DateTime date) {
    final weekStart = getWeekStart(date);
    return getDayEnd(weekStart.add(const Duration(days: 6)));
  }

  /// 월의 시작일 구하기
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 월의 마지막일 구하기
  static DateTime getMonthEnd(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return getDayEnd(lastDay);
  }

  /// 년의 시작일 구하기
  static DateTime getYearStart(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// 년의 마지막일 구하기
  static DateTime getYearEnd(DateTime date) {
    return getDayEnd(DateTime(date.year, 12, 31));
  }

  /// 이전 날짜 구하기
  static DateTime getPreviousDay(DateTime date) {
    return date.subtract(const Duration(days: 1));
  }

  /// 다음 날짜 구하기
  static DateTime getNextDay(DateTime date) {
    return date.add(const Duration(days: 1));
  }

  /// 이전 주 구하기
  static DateTime getPreviousWeek(DateTime date) {
    return date.subtract(const Duration(days: 7));
  }

  /// 다음 주 구하기
  static DateTime getNextWeek(DateTime date) {
    return date.add(const Duration(days: 7));
  }

  /// 이전 달 구하기
  static DateTime getPreviousMonth(DateTime date) {
    if (date.month == 1) {
      return DateTime(date.year - 1, 12, date.day);
    }
    return DateTime(date.year, date.month - 1, date.day);
  }

  /// 다음 달 구하기
  static DateTime getNextMonth(DateTime date) {
    if (date.month == 12) {
      return DateTime(date.year + 1, 1, date.day);
    }
    return DateTime(date.year, date.month + 1, date.day);
  }

  /// 이전 년도 구하기
  static DateTime getPreviousYear(DateTime date) {
    return DateTime(date.year - 1, date.month, date.day);
  }

  /// 다음 년도 구하기
  static DateTime getNextYear(DateTime date) {
    return DateTime(date.year + 1, date.month, date.day);
  }

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// DateUnit에 따른 날짜 범위 구하기
  static DateTimeRange getDateRangeByUnit(DateUnit unit, [DateTime? date]) {
    final targetDate = date ?? DateTime.now();

    switch (unit) {
      case DateUnit.day:
        return DateTimeRange(
          start: getDayStart(targetDate),
          end: getDayEnd(targetDate),
        );

      case DateUnit.week:
        return DateTimeRange(
          start: getWeekStart(targetDate),
          end: getWeekEnd(targetDate),
        );

      case DateUnit.month:
        return DateTimeRange(
          start: getMonthStart(targetDate),
          end: getMonthEnd(targetDate),
        );

      case DateUnit.year:
        return DateTimeRange(
          start: getYearStart(targetDate),
          end: getYearEnd(targetDate),
        );
    }
  }

  /// DateUnit에 따른 포맷된 날짜 문자열 반환
  static String getFormattedDateRange(DateUnit unit, [DateTime? date]) {
    final range = getDateRangeByUnit(unit, date);

    switch (unit) {
      case DateUnit.day:
        return _formatDate(range.start);

      case DateUnit.week:
        return '${_formatDate(range.start)} ~ ${_formatDate(range.end)}';

      case DateUnit.month:
        return '${range.start.year}.${range.start.month.toString().padLeft(2, '0')}';

      case DateUnit.year:
        return '${range.start.year}';
    }
  }

  /// 날짜를 'yyyy.MM.dd' 형식으로 포맷
  static String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// Firestore 타임스탬프를 DateTime으로 변환
  /// Firestore의 Timestamp 객체나 Map 형태의 타임스탬프를 처리
  static DateTime? parseFirestoreTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    // Firestore Timestamp 객체인 경우
    if (timestamp is Map<String, dynamic>) {
      if (timestamp.containsKey('_seconds')) {
        final seconds = timestamp['_seconds'] as int;
        final nanoseconds = timestamp['_nanoseconds'] as int? ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ~/ 1000000),
        );
      }
    }

    // ISO 문자열 형식인 경우
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }

    // Unix 타임스탬프 (초 단위)인 경우
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }

    // Unix 타임스탬프 (밀리초 단위)인 경우
    if (timestamp is double) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    }

    return null;
  }

  /// Firestore 타임스탬프를 DateTime으로 변환 (기본값 포함)
  /// 변환에 실패하면 기본값을 반환
  static DateTime parseFirestoreTimestampWithDefault(
    dynamic timestamp, {
    DateTime? defaultValue,
  }) {
    final parsed = parseFirestoreTimestamp(timestamp);
    return parsed ?? defaultValue ?? DateTime.now();
  }

  /// DateTime을 Firestore 타임스탬프 Map으로 변환
  static Map<String, dynamic> toFirestoreTimestamp(DateTime dateTime) {
    final milliseconds = dateTime.millisecondsSinceEpoch;
    final seconds = milliseconds ~/ 1000;
    final nanoseconds = (milliseconds % 1000) * 1000000;

    return {
      '_seconds': seconds,
      '_nanoseconds': nanoseconds,
    };
  }

  /// DateTime을 Unix 타임스탬프 (초 단위)로 변환
  static int toUnixTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// DateTime을 Unix 타임스탬프 (밀리초 단위)로 변환
  static int toUnixTimestampMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({
    required this.start,
    required this.end,
  });
}
