import 'package:flutter/material.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';

/// 앱 전역 테마. TDS 다크 팔레트 하나만 쓴다 — 라이트 모드는 지원하지 않는다.
///
/// 화면 대부분은 `lib/widgets/tds/`의 위젯이 토큰을 직접 참조하므로, 여기서는
/// Material 기본 위젯(다이얼로그, 스낵바 등)이 튀지 않을 만큼만 맞춰준다.
abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: TdsColors.brand,
      onPrimary: TdsColors.textOnFill,
      secondary: TdsColors.brandText,
      onSecondary: TdsColors.textOnFill,
      error: TdsColors.danger,
      onError: TdsColors.textOnFill,
      surface: TdsColors.background,
      onSurface: TdsColors.textPrimary,
      outline: TdsColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TdsColors.backgroundLower,
      canvasColor: TdsColors.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerTheme: const DividerThemeData(
        color: TdsColors.border,
        thickness: TdsSize.borderThin,
        space: TdsSize.borderThin,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: TdsColors.brand,
        selectionColor: TdsColors.brandWeak,
        selectionHandleColor: TdsColors.brand,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TdsColors.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TdsRadius.dialog),
        ),
        titleTextStyle: TdsText.subtitle,
        contentTextStyle: TdsText.body,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: TdsColors.brand,
      ),
      textTheme: const TextTheme(
        headlineMedium: TdsText.title,
        titleMedium: TdsText.subtitle,
        bodyLarge: TdsText.body,
        bodyMedium: TdsText.body,
        labelSmall: TdsText.caption,
      ),
    );
  }
}
