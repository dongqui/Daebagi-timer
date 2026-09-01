import 'package:flutter/material.dart';

import 'package:catodo/core/utils/duration_format.dart';
import 'package:catodo/features/data/models/focus_session_model.dart';
import 'package:catodo/features/presentation/viewmodels/focus_end_alert.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/space_backdrop.dart';
import 'package:catodo/widgets/tds/tds_bottom_cta.dart';
import 'package:catodo/widgets/tds/tds_button.dart';
import 'package:catodo/widgets/tds/tds_list_row.dart';
import 'package:catodo/widgets/tds/tds_loader.dart';
import 'package:catodo/widgets/tds/tds_text_button.dart';

/// 집중이 끝났을 때 뜨는 화면. 세션을 저장하고 결과를 요약해 보여준다.
class FocusEndOverlay extends StatefulWidget {
  const FocusEndOverlay({super.key});

  @override
  State<FocusEndOverlay> createState() => _FocusEndOverlayState();
}

class _FocusEndOverlayState extends State<FocusEndOverlay> {
  /// 저장 전에는 null. 저장이 끝나야 "마친 시각"을 알 수 있다.
  FocusSession? _session;

  @override
  void initState() {
    super.initState();

    // 목표를 채워서 저절로 끝났을 때만 울린다. 직접 그만둔 사람은 화면을
    // 보고 있으니 알릴 이유가 없다.
    if (TimerManager.instance.reachedGoal) {
      FocusEndAlert.instance.fire();
    }

    _saveSession();
  }

  Future<void> _saveSession() async {
    final focussedTime = TimerManager.instance.state.focussedTime;
    final session = await FormManager.instance.save(focussedTime);
    if (mounted) setState(() => _session = session);
  }

  @override
  Widget build(BuildContext context) {
    final focussedTime = TimerManager.instance.state.focussedTime;
    final session = _session;

    return ColoredBox(
      color: TdsColors.background,
      child: Column(
        children: [
          // 완료 연출 영역. 디자인에서 게임 엔진이 그리기로 한 자리다.
          const SizedBox(
            height: 300,
            width: double.infinity,
            child: SpaceBackdrop(moon: true, moonAlignment: Alignment(1.2, 0.4)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TdsSpacing.pageMarginM,
              28,
              TdsSpacing.pageMarginM,
              4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${formatHumanDuration(focussedTime)} 집중을 마쳤어요',
                    style: TdsText.title,
                  ),
                ),
                const SizedBox(height: TdsSpacing.gapS),
                Text(
                  session == null ? '기록에 저장하는 중이에요' : '기록에 저장했어요',
                  style: TdsText.body.copyWith(color: TdsColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (session == null)
            const Expanded(
              child: Center(child: TdsLoader(size: 28)),
            )
          else ...[
            TdsListRow(
              title: '집중한 일',
              right: TdsListRow.value(
                session.activity.isEmpty ? '이름 없는 세션' : session.activity,
              ),
            ),
            TdsListRow(
              title: '집중한 시간',
              right: TdsListRow.value(formatHumanDuration(session.focusedTime)),
            ),
            TdsListRow(
              title: '마친 시각',
              right: TdsListRow.value(formatTimeOfDay(session.date)),
            ),
            const Spacer(),
          ],
          TdsBottomCta(
            gradient: false,
            lowerItem: TdsTextButton(
              label: '기록 보기',
              size: TdsTextButtonSize.m,
              fullWidth: true,
              onPressed: () => TimerManager.instance.goToStats(),
            ),
            child: TdsButton(
              label: '한 번 더 집중하기',
              size: TdsButtonSize.xl,
              fullWidth: true,
              onPressed: () => TimerManager.instance.save(),
            ),
          ),
        ],
      ),
    );
  }
}
