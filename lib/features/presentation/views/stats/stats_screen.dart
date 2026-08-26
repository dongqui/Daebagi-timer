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
/// 상단 캐릭터 영역을 누르거나 우측 상단 꾸미기 버튼을 누르면 캐릭터를 바꿀 수 있다.
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
          TdsNavigation(
            leading: TdsIconButton(
              icon: const Icon(Icons.close_rounded),
              size: TdsIconButtonSize.l,
              variant: TdsIconButtonVariant.clear,
              color: TdsColors.textStrong,
              semanticLabel: '닫기',
              onPressed: widget.onClose,
            ),
            leftItems: [
              TdsIconButton(
                icon: const Icon(Icons.edit_rounded),
                size: TdsIconButtonSize.l,
                variant: TdsIconButtonVariant.fill,
                color: TdsColors.textStrong,
                semanticLabel: '캐릭터 꾸미기',
                onPressed: _openCharacterSelectors,
              ),
            ],
          ),
          Expanded(
            child: ColoredBox(
              color: TdsColors.background,
              child: Column(
                children: [
                  // 캐릭터만 놓고 배경은 검정으로 둔다. 별을 깔면 아래 차트
                  // 영역과 겹쳐 보여서 캐릭터가 묻힌다.
                  const ColoredBox(
                    color: TdsColors.canvas,
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: CharacterSettingOverlay(),
                    ),
                  ),
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
