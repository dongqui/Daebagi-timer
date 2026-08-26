import 'package:flutter/material.dart';

import 'package:catodo/core/utils/duration_format.dart';
import 'package:catodo/features/presentation/viewmodels/audio_controller.dart';
import 'package:catodo/features/presentation/viewmodels/audio_state.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/audio_box.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/background_to_tab_in_stack.dart';
import 'package:catodo/widgets/tds/tds_glass_panel.dart';
import 'package:catodo/widgets/tds/tds_icon_button.dart';

/// 집중이 진행되는 동안 게임 화면 위에 얹히는 컨트롤.
///
/// 배경은 그리지 않는다 — 뒤에서 Flame 타이머 월드가 돌고 있다.
class TimerOverlay extends StatefulWidget {
  const TimerOverlay({super.key});

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay> {
  final _timerManager = TimerManager.instance;

  /// 패널이 아니라 화면이 들고 있다. 패널을 닫아도 소리는 계속 나야 한다.
  final AudioController _audioController = AudioController();

  late TimerState _timerState;
  bool _isAudioBoxVisible = false;

  @override
  void initState() {
    super.initState();
    _timerState = _timerManager.state;
    _timerManager.addListener(_handleTimerStateChanged);
    _initAudio();
  }

  @override
  void dispose() {
    _timerManager.removeListener(_handleTimerStateChanged);
    _audioController.dispose();
    super.dispose();
  }

  /// 저장된 백색소음 선택을 실제 재생으로 이어준다.
  /// 이게 없으면 체크는 되어 있는데 소리는 안 나는 상태가 된다.
  Future<void> _initAudio() async {
    await _audioController.preload(whiteNoiseTypes);
    await AudioManager.instance.getAudioList();
    if (!mounted) return;

    final selected = AudioManager.instance.state.whiteNoise;
    for (final type in whiteNoiseTypes) {
      if (selected.contains(type.name)) _audioController.play(type);
    }
  }

  void _handleTimerStateChanged(TimerState state) {
    if (mounted) setState(() => _timerState = state);
  }

  void _toggleAudioBox() {
    setState(() => _isAudioBoxVisible = !_isAudioBoxVisible);
  }

  Future<void> _confirmFinish() async {
    final wasRunning = _timerState.status == TimerStatus.running;
    _timerManager.pause();

    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('집중을 그만둘까요?'),
        content: const Text('지금까지 집중한 시간은 기록에 남아요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('그만두기'),
          ),
        ],
      ),
    );

    if (shouldFinish == true) {
      _timerManager.finish();
    } else if (wasRunning) {
      _timerManager.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final running = _timerState.status == TimerStatus.running;
    final activity = FormManager.instance.state.activity;

    return Stack(
      children: [
        if (_isAudioBoxVisible)
          BackgroundToTabInStack(onTap: _toggleAudioBox),

        // 무엇을 얼마나 집중하고 있는지.
        //
        // 캐릭터는 화면 세로 중앙(`TimerTraveller`)에 뜬다. 시계를 맨 위에 붙이면
        // 캐릭터와 너무 떨어져 보여서, 화면 위쪽 끝과 캐릭터의 중간쯤에 놓는다.
        Align(
          alignment: const Alignment(0, -0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TdsSpacing.pageMarginM,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    activity.isEmpty ? '집중 중' : activity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TdsText.bodyMedium.copyWith(
                      color: TdsColors.onCanvasMedium,
                    ),
                  ),
                ),
                const SizedBox(height: TdsSpacing.gapS),
                Text(
                  formatTimerClock(_timerState.focussedTime),
                  style: TdsText.timer,
                ),
              ],
            ),
          ),
        ),

        // 백색소음 패널. 컨트롤 바에서 가장 왼쪽에 있는 음표 아이콘 바로 위에
        // 오도록 오른쪽 기준으로 붙인다 — 아이콘에서 튀어나온 것처럼 보이게.
        if (_isAudioBoxVisible)
          Positioned(
            right: 16,
            bottom: 120,
            width: 212,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: TdsMotion.fast,
              curve: TdsMotion.emphasized,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.92 + 0.08 * t,
                  alignment: Alignment.bottomRight,
                  child: child,
                ),
              ),
              child: AudioBox(controller: _audioController),
            ),
          ),

        Positioned(
          right: 16,
          bottom: 36,
          child: TdsGlassPanel(
            elevated: true,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TdsIconButton(
                  icon: const Icon(Icons.music_note_rounded),
                  variant: TdsIconButtonVariant.clear,
                  color: _isAudioBoxVisible
                      ? TdsColors.brand
                      : TdsColors.onCanvasIcon,
                  semanticLabel: '백색소음',
                  onPressed: _toggleAudioBox,
                ),
                const SizedBox(width: 4),
                TdsIconButton(
                  icon: Icon(
                    running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  variant: TdsIconButtonVariant.clear,
                  color: TdsColors.onCanvasIcon,
                  semanticLabel: running ? '일시정지' : '계속하기',
                  onPressed: running ? _timerManager.pause : _timerManager.start,
                ),
                const SizedBox(width: 4),
                TdsIconButton(
                  icon: const Icon(Icons.stop_rounded),
                  variant: TdsIconButtonVariant.clear,
                  color: TdsColors.onCanvasIcon,
                  semanticLabel: '종료',
                  onPressed: _confirmFinish,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
