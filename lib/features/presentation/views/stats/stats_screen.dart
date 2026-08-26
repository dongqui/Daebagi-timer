import 'package:flutter/material.dart';

import 'package:catodo/core/utils/duration_format.dart';
import 'package:catodo/features/presentation/viewmodels/chart_state.dart';
import 'package:catodo/features/presentation/views/character_selectors.dart';
import 'package:catodo/features/presentation/views/dashboard/widgets/charts/focus_chart_per_date_unit.dart';
import 'package:catodo/features/presentation/views/overlays/settings/character_setting.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/tds/tds_arrow.dart';
import 'package:catodo/widgets/tds/tds_border.dart';
import 'package:catodo/widgets/tds/tds_icon_button.dart';
import 'package:catodo/widgets/tds/tds_list_row.dart';
import 'package:catodo/widgets/tds/tds_navigation.dart';
import 'package:catodo/widgets/tds/tds_segmented_control.dart';

/// 집중 기록 화면.
///
/// 기간 단위를 고르고, 그 구간의 세션을 차트와 합계로 보여준다.
/// 상단 캐릭터 영역이나 그 위의 꾸미기 칩을 누르면 캐릭터를 바꿀 수 있다.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  ChartState _state = ChartManager.instance.state;

  @override
  void initState() {
    super.initState();
    ChartManager.instance.addListener(_onChartStateChanged);
    ChartManager.instance.getFocusSessions();
  }

  @override
  void dispose() {
    ChartManager.instance.removeListener(_onChartStateChanged);
    super.dispose();
  }

  void _onChartStateChanged(ChartState state, ChartState? _) {
    if (mounted) setState(() => _state = state);
  }

  void _openCharacterSelectors() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: TdsColors.canvas,
        insetPadding: EdgeInsets.zero,
        child: CharacterSelectors(onClose: () => Navigator.of(context).pop()),
      ),
    );
  }

  /// 화면에 보이는 구간의 총 집중 시간(초).
  int get _totalSeconds => _state.focusSessions.fold(
        0,
        (sum, series) =>
            sum + series.fold<int>(0, (inner, tuple) => inner + tuple.$2),
      );

  /// 화면에 보이는 구간의 세션 수.
  int get _sessionCount =>
      _state.focusSessions.fold(0, (sum, series) => sum + series.length);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TdsColors.backgroundLower,
      child: Column(
        children: [
          // 내비게이션 바와 캐릭터 자리를 한 덩어리 검정으로 묶는다. 바에만 다른
          // 색을 칠하면 둘이 만나는 지점에 가로줄이 생긴다.
          ColoredBox(
            color: TdsColors.canvas,
            child: Column(
              children: [
                TdsNavigation(
                  leading: TdsIconButton(
                    icon: const Icon(Icons.close_rounded),
                    size: TdsIconButtonSize.l,
                    variant: TdsIconButtonVariant.clear,
                    color: TdsColors.onCanvasIcon,
                    semanticLabel: '닫기',
                    onPressed: widget.onClose,
                  ),
                ),
                // 캐릭터만 놓고 배경은 검정으로 둔다. 별을 깔면 아래 차트
                // 영역과 겹쳐 보여서 캐릭터가 묻힌다.
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: CharacterSettingOverlay()),
                      // 꾸미기는 내비게이션 바에서 여기로 내렸다. 바 오른쪽 끝은
                      // 토스 더보기·닫기 자리라 우리 버튼을 둘 수 없다.
                      Positioned(
                        right: 16,
                        bottom: 14,
                        child: _DecorateChip(onPressed: _openCharacterSelectors),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: TdsColors.background,
              child: Column(
                children: [
                  const TdsBorder.thick(),
                  const SizedBox(height: 8),
                  TdsSegmentedControl<DateUnit>(
                    items: DateUnit.values,
                    value: _state.currentDateUnit,
                    size: TdsSegmentedSize.s,
                    labelOf: _dateUnitLabel,
                    onChanged: ChartManager.instance.updateDateUnit,
                  ),
                  _RangeSelector(
                    label: ChartManager.instance.getFormattedDateRange(),
                    onPrevious: ChartManager.instance.movePrevious,
                    onNext: ChartManager.instance.moveNext,
                  ),
                  Expanded(
                    child: ColoredBox(
                      color: TdsColors.canvas,
                      child: const FocusChartPerDateUnit(),
                    ),
                  ),
                  const TdsBorder.thick(),
                  TdsListRow(
                    title: '총 집중 시간',
                    right: TdsListRow.value(
                      _totalSeconds == 0
                          ? '0초'
                          : formatHumanDuration(_totalSeconds),
                    ),
                  ),
                  TdsListRow(
                    title: '세션',
                    right: TdsListRow.value('$_sessionCount회'),
                  ),
                  SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _dateUnitLabel(DateUnit unit) => switch (unit) {
      DateUnit.day => '일',
      DateUnit.week => '주',
      DateUnit.month => '월',
      DateUnit.year => '년',
    };

/// 보고 있는 기간과 앞뒤 이동 버튼.
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: TdsSpacing.pageMarginXs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TdsIconButton(
              icon: const TdsArrow(direction: TdsArrowDirection.left, size: 20),
              variant: TdsIconButtonVariant.clear,
              semanticLabel: '이전',
              onPressed: onPrevious,
            ),
            // 주 단위 라벨('2026.08.24 ~ 2026.08.30')은 좁은 화면이나 큰 글자
            // 설정에서 두 버튼 사이에 그대로는 안 들어간다. 자르는 대신 줄인다 —
            // 날짜는 뒷부분이 잘리면 의미가 사라진다.
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: TdsText.bodySemibold),
              ),
            ),
            TdsIconButton(
              icon: const TdsArrow(direction: TdsArrowDirection.right, size: 20),
              variant: TdsIconButtonVariant.clear,
              semanticLabel: '다음',
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

/// 캐릭터 자리 위에 얹는 "꾸미기" 칩.
///
/// 디자인의 TDS Chip(size S · pill · weak)을 옮겼다. 여기서만 쓰므로 공용
/// 위젯으로 올리지 않는다 — 다른 화면에도 생기면 그때 tds/로 승격한다.
class _DecorateChip extends StatelessWidget {
  const _DecorateChip({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '캐릭터 꾸미기',
      // 안쪽 '꾸미기' 텍스트까지 읽히면 라벨이 겹쳐 들린다.
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: TdsColors.fillNeutralWeak,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 16, color: TdsColors.onCanvasIcon),
              SizedBox(width: 4),
              Text(
                '꾸미기',
                style: TextStyle(
                  fontSize: 13,
                  height: 19.5 / 13,
                  fontWeight: FontWeight.w600,
                  color: TdsColors.onCanvasIcon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
