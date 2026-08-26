import 'package:flutter/material.dart';

import 'package:catodo/core/utils/duration_format.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/tds/tds_list_header.dart';
import 'package:catodo/widgets/tds/tds_numeric_spinner.dart';

/// 집중할 시간을 시/분/초 스피너로 고른다.
///
/// 세 스피너의 합이 곧 목표 시간이라, 값이 바뀔 때마다 폼과 타이머 양쪽에 밀어넣는다.
class FocusTimeInputWidget extends StatefulWidget {
  const FocusTimeInputWidget({super.key});

  @override
  State<FocusTimeInputWidget> createState() => _FocusTimeInputWidgetState();
}

class _FocusTimeInputWidgetState extends State<FocusTimeInputWidget> {
  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    // 저장된 목표 시간이 음수면(예전 '무제한' 값) 기본값으로 되돌린다.
    final duration = FormManager.instance.state.duration;
    final safeDuration = duration < 0 ? 0 : duration;
    _hours = safeDuration ~/ 3600;
    _minutes = (safeDuration ~/ 60) % 60;
    _seconds = safeDuration % 60;
    // 화면에 처음 보이는 값과 실제 목표 시간을 일치시킨다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _publish());
  }

  int get _totalSeconds => _hours * 3600 + _minutes * 60 + _seconds;

  void _publish() {
    FormManager.instance.updateDuration(_totalSeconds);
    TimerManager.instance.updateGoalTime(_totalSeconds);
  }

  void _update(void Function() change) {
    setState(change);
    _publish();
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalSeconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TdsListHeader(
          title: '얼마나 집중하실 건가요?',
          verticalPadding: TdsListHeaderPadding.s,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TdsSpacing.pageMarginM,
            8,
            TdsSpacing.pageMarginM,
            0,
          ),
          child: Row(
            children: [
              _SpinnerColumn(
                label: '시간',
                value: _hours,
                max: 12,
                onChanged: (v) => _update(() => _hours = v),
              ),
              const SizedBox(width: TdsSpacing.gapS),
              _SpinnerColumn(
                label: '분',
                value: _minutes,
                max: 59,
                onChanged: (v) => _update(() => _minutes = v),
              ),
              const SizedBox(width: TdsSpacing.gapS),
              _SpinnerColumn(
                label: '초',
                value: _seconds,
                max: 59,
                onChanged: (v) => _update(() => _seconds = v),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            TdsSpacing.pageMarginM,
            14,
            TdsSpacing.pageMarginM,
            8,
          ),
          child: Text(
            total > 0 ? '총 ${formatHumanDuration(total)} 집중' : '시간을 골라주세요',
            textAlign: TextAlign.center,
            style: TdsText.bodySemibold.copyWith(
              color: total > 0 ? TdsColors.brandText : TdsColors.textQuaternary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpinnerColumn extends StatelessWidget {
  const _SpinnerColumn({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TdsText.captionMedium),
          const SizedBox(height: TdsSpacing.gapS),
          TdsNumericSpinner(
            value: value,
            max: max,
            size: TdsNumericSpinnerSize.xs,
            semanticLabel: label,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
