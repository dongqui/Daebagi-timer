import 'package:flutter/material.dart';

import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/tds/tds_text_field.dart';

/// 무엇에 집중할지 적는 입력. 아래에 최근에 쓴 활동을 칩으로 다시 꺼낼 수 있다.
class FocusActivityInputWidget extends StatefulWidget {
  const FocusActivityInputWidget({super.key});

  @override
  State<FocusActivityInputWidget> createState() =>
      _FocusActivityInputWidgetState();
}

class _FocusActivityInputWidgetState extends State<FocusActivityInputWidget> {
  final TextEditingController _controller = TextEditingController();
  List<String> _recentActivities = const [];

  @override
  void initState() {
    super.initState();
    _controller.text = FormManager.instance.state.activity;
    FormManager.instance.addListener(_onFormStateChanged);
    FormManager.instance.getLatestActivities();
  }

  @override
  void dispose() {
    FormManager.instance.removeListener(_onFormStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onFormStateChanged(FocusFormState state) {
    if (!mounted) return;
    setState(() => _recentActivities = state.latestActivities);
  }

  void _applyRecent(String activity) {
    _controller.text = activity;
    _controller.selection =
        TextSelection.collapsed(offset: activity.length);
    FormManager.instance.updateActivity(activity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TdsTextField(
          controller: _controller,
          label: '어떤 일에 집중하실 건가요?',
          // 아래 '얼마나 집중하실 건가요?'(TdsListHeader)와 같은 급으로 맞춘다.
          labelStyle: TdsText.subtitle,
          placeholder: '예: 수학 문제 풀기, 영어 단어 외우기',
          textInputAction: TextInputAction.done,
          onChanged: FormManager.instance.updateActivity,
        ),
        if (_recentActivities.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: TdsSpacing.pageMarginM,
            ),
            child: Row(
              children: [
                for (final activity in _recentActivities)
                  Padding(
                    padding: const EdgeInsets.only(right: TdsSpacing.gapM),
                    child: _RecentActivityChip(
                      label: activity,
                      onTap: () => _applyRecent(activity),
                      onDelete: () =>
                          FormManager.instance.removeLatestActivity(activity),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecentActivityChip extends StatelessWidget {
  const _RecentActivityChip({
    required this.label,
    required this.onTap,
    required this.onDelete,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.only(left: 12, right: 6),
        decoration: BoxDecoration(
          color: TdsColors.fillNeutralWeak,
          borderRadius: BorderRadius.circular(TdsRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TdsText.captionMedium.copyWith(
                color: TdsColors.textSecondary,
              ),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: TdsColors.iconTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
