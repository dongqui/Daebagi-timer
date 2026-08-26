import 'package:flutter/painting.dart';

import 'package:catodo/theme/tds_colors.dart';

/// TDS 타이포그래피 스케일 중 디자인이 실제로 쓰는 것만.
///
/// CSS의 가변 폰트 웨이트를 Flutter 웨이트로 옮긴다: 510 → `w500`, 590 → `w600`.
/// `height`는 CSS `line-height ÷ font-size` 비율이다 (본문 1.5, 타이틀 1.35).
///
/// 색은 대부분 [TdsColors.textPrimary]로 두고, 쓰는 쪽에서 `copyWith(color:)`로
/// 덮는다. 게임 캔버스 위에 얹는 텍스트는 `onCanvas*` 계열을 쓸 것.
abstract final class TdsText {
  /// 타이머 숫자. 자릿수가 바뀌어도 폭이 흔들리지 않게 tabular figures를 쓴다.
  static const timer = TextStyle(
    fontSize: 44,
    height: 52 / 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.44,
    color: TdsColors.onCanvasStrong,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 화면 제목. 인트로 타이틀과 완료 화면 헤드라인.
  static const title = TextStyle(
    fontSize: 24,
    height: 32.4 / 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24,
    color: TdsColors.textStrong,
  );

  /// 섹션 제목 · 빈 상태 헤드라인.
  static const subtitle = TextStyle(
    fontSize: 17,
    height: 25.5 / 17,
    fontWeight: FontWeight.w700,
    color: TdsColors.textStrong,
  );

  static const bodyBold = TextStyle(
    fontSize: 15,
    height: 22.5 / 15,
    fontWeight: FontWeight.w700,
    color: TdsColors.textStrong,
  );

  /// CSS 590. 강조된 값 — 기간 라벨, 합계 라벨.
  static const bodySemibold = TextStyle(
    fontSize: 15,
    height: 22.5 / 15,
    fontWeight: FontWeight.w600,
    color: TdsColors.textStrong,
  );

  /// CSS 510. 라벨성 본문.
  static const bodyMedium = TextStyle(
    fontSize: 15,
    height: 22.5 / 15,
    fontWeight: FontWeight.w500,
    color: TdsColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 22.5 / 15,
    fontWeight: FontWeight.w400,
    color: TdsColors.textPrimary,
  );

  /// CSS 510. 캡션 · 범례 · 스피너 열 제목.
  static const captionMedium = TextStyle(
    fontSize: 13,
    height: 19.5 / 13,
    fontWeight: FontWeight.w500,
    color: TdsColors.textTertiary,
  );

  static const caption = TextStyle(
    fontSize: 13,
    height: 19.5 / 13,
    fontWeight: FontWeight.w400,
    color: TdsColors.textQuaternary,
  );
}
