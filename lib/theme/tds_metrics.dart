import 'package:flutter/animation.dart';

/// TDS의 치수 토큰 — 라운딩, 여백, 컨트롤 높이, 블러, 모션.
///
/// 값 출처는 `tokens/aliases.css`와 각 컴포넌트 구현이다.
abstract final class TdsRadius {
  static const buttonS = 8.0;
  static const buttonM = 10.0;
  static const buttonL = 14.0;
  static const buttonXL = 16.0;
  static const iconButton = 13.0;
  static const textField = 14.0;
  static const segmentedS = 12.0;
  static const segmentedL = 14.0;
  static const panel = 20.0;
  static const sheet = 28.0;
  static const dialog = 24.0;

  /// 알약 모양. CSS의 `999px`.
  static const full = 999.0;
}

abstract final class TdsSpacing {
  /// 화면 좌우 기본 여백. TDS 본문 기준값.
  static const pageMarginXs = 16.0;
  static const pageMarginS = 20.0;
  static const pageMarginM = 24.0;

  static const gapS = 6.0;
  static const gapM = 8.0;

  static const listRowPaddingY = 16.0;
  static const listRowPaddingX = 24.0;
}

abstract final class TdsSize {
  // 버튼 높이 — S/M/L/XL.
  static const buttonS = 32.0;
  static const buttonM = 38.0;
  static const buttonL = 48.0;
  static const buttonXL = 56.0;

  // 아이콘 버튼 히트 영역.
  static const iconButtonM = 38.0;
  static const iconButtonL = 44.0;

  static const segmentedS = 40.0;
  static const segmentedL = 48.0;

  static const numericSpinnerXs = 34.0;
  static const numericSpinnerXsButton = 24.0;

  /// `TdsBorder(thick: true)`의 두께. 섹션 구분 띠.
  static const borderThick = 16.0;
  static const borderThin = 1.0;

  /// 상단 내비게이션 바 본체 높이 (상태 표시줄 제외).
  static const navigationBar = 56.0;
}

abstract final class TdsBlur {
  /// 게임 캔버스 위 유리 패널. 디자인의 `backdrop-filter: blur(22px)`.
  ///
  /// CSS blur radius와 Flutter의 sigma는 단위가 달라 대략 절반으로 환산한다.
  static const glassSigma = 11.0;
}

abstract final class TdsMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const sheet = Duration(milliseconds: 320);

  /// 화면 전환처럼 존재감이 필요한 모션.
  static const emphasized = Cubic(0.32, 0.72, 0, 1);
  static const standard = Cubic(0.25, 0.1, 0.25, 1);
}
