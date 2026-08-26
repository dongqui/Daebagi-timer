import 'package:flutter/painting.dart';

/// TDS(토스 디자인 시스템) 다크 테마 시맨틱 컬러.
///
/// Figma Variables(`tokens/fig-tokens.css`)의 `:root[data-theme="dark"]` 블록 값을
/// 그대로 옮긴 것이다. 눈대중으로 조정하지 말고 디자인 시스템에서 다시 받아올 것.
/// 앱은 다크 전용이라 라이트 팔레트는 정의하지 않는다.
abstract final class TdsColors {
  // ── 배경 ──────────────────────────────────────────────────────────────
  /// `semantic/background/default` — 시트·카드 등 기본 표면.
  static const background = Color(0xFF17171C);

  /// `semantic/background/lower` — 화면 최하단 레이어.
  static const backgroundLower = Color(0xFF101013);

  /// `semantic/background/floated` — 입력 필드처럼 한 단 떠 있는 표면.
  static const backgroundFloated = Color(0xFF202027);

  /// `semantic/background/dim` — 모달 뒤 딤.
  static const backgroundDim = Color(0x8F000000);

  /// 게임 엔진이 그리는 영역. 디자인에서 순수 검정으로 남겨둔 부분이다.
  static const canvas = Color(0xFF000000);

  // ── 텍스트 ────────────────────────────────────────────────────────────
  static const textStrong = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFFE4E4E5);
  static const textSecondary = Color(0xBFFDFDFF);
  static const textTertiary = Color(0x99F8F8FF);
  static const textQuaternary = Color(0x78F2F2FF);

  /// 채워진 버튼 위에 얹는 텍스트.
  static const textOnFill = Color(0xFFFFFFFF);

  // ── 아이콘 ────────────────────────────────────────────────────────────
  static const iconPrimary = Color(0x99F8F8FF);
  static const iconSecondary = Color(0x78F2F2FF);
  static const iconTertiary = Color(0x5CE8E8FD);
  static const iconQuaternary = Color(0x45E0E0FF);

  // ── 브랜드 · 상태 ─────────────────────────────────────────────────────
  /// `semantic/fill/brand` — 버튼 배경 등 채움용 파랑.
  static const brand = Color(0xFF3182F6);

  /// `semantic/text/brand` — 다크에서 텍스트로 쓸 때는 한 톤 밝다.
  static const brandText = Color(0xFF449BFF);
  static const brandWeak = Color(0x293182F6);

  /// `weak` 버튼의 라벨색. 옅은 채움 위에서 읽히려면 텍스트가 훨씬 밝아야 한다.
  static const brandWeakText = Color(0xFF8FCDFF);

  static const danger = Color(0xFFF04251);
  static const dangerWeak = Color(0x29F04452);
  static const dangerWeakText = Color(0xFFFFA8AD);
  static const success = Color(0xFF16BB76);
  static const warning = Color(0xFFFFB134);

  // ── 선 · 채움 ─────────────────────────────────────────────────────────
  static const border = Color(0x30DEDEFF);

  /// `semantic/border/thick` — 섹션을 가르는 두꺼운 띠. 색이 곧 배경보다 어둡다.
  static const borderThick = Color(0xFF101013);

  static const fillNeutral = Color(0xFF62626D);
  static const fillNeutralWeak = Color(0x1CD9D9FF);
  static const fillInverse = Color(0xFFFFFFFF);
  static const fillInverseWeak = Color(0x30DEDEFF);

  /// 리스트 행 등을 눌렀을 때 얹는 면. 버튼은 대신 검정 26%를 쓴다.
  static const fillPressed = Color(0x1CD9D9FF);

  // ── 컴포넌트 전용 ─────────────────────────────────────────────────────
  static const textFieldBoxFill = Color(0xFF202027);
  static const textFieldBoxFillFocused = Color(0x1C4786EB);
  static const textFieldBorderFocused = Color(0xFF3485FA);
  static const textFieldBorderError = Color(0xFFF04251);
  static const numericSpinnerFieldFill = Color(0xFF62626D);
  static const numericSpinnerFieldText = Color(0xFFE4E4E5);

  // ── 게임 화면 위 유리 패널 ─────────────────────────────────────────────
  // 디자인에서 홈 메뉴·타이머 컨트롤·백색소음 패널에 반복해서 쓰는 값.
  static const glassFill = Color(0xD11C1E24);
  static const glassRing = Color(0x1AFDFDFF);

  // ── 검은 배경 위 흰 글자 ───────────────────────────────────────────────
  // 게임 캔버스 위에 얹히는 텍스트는 시맨틱 토큰 대신 순수 흰색 알파를 쓴다.
  // 시맨틱 토큰은 미세하게 푸른기가 있어 캔버스 위에서 탁해 보인다.
  static const onCanvasStrong = Color(0xFFFFFFFF);
  static const onCanvasHigh = Color(0xE0FFFFFF);
  static const onCanvasMedium = Color(0x99FFFFFF);
  static const onCanvasLow = Color(0x80FFFFFF);
  static const onCanvasIcon = Color(0xEBFFFFFF);
}
