import 'package:flutter/material.dart';

import 'package:catodo/features/presentation/viewmodels/characater_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/stats/stats_screen.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/widgets/full_screen_overlay.dart';
import 'package:catodo/widgets/tds/tds_glass_panel.dart';
import 'package:catodo/widgets/tds/tds_icon_button.dart';

/// 홈 화면 위에 얹히는 컨트롤. 뒤에서는 Flame 홈 월드가 돌고 있다.
class HomeOverlay extends StatefulWidget {
  const HomeOverlay({super.key});

  @override
  HomeOverlayState createState() => HomeOverlayState();
}

class HomeOverlayState extends State<HomeOverlay>
    with SingleTickerProviderStateMixin {
  bool _isStatsOpen = false;

  @override
  void initState() {
    super.initState();
    CharacterManager.instance.initSelectedCharacter();
    TimerManager.instance.addListenerToStatus(_onTimerStatusChanged);
    // 완료 화면에서 '기록 보기'로 넘어온 경우다. 첫 프레임부터 기록 화면이
    // 올라와 있어야 홈이 한 번 깜빡이지 않는다 — 그래서 postFrame이 아니라
    // 여기서 바로 켠다.
    _isStatsOpen = _shouldOpenStats();
  }

  /// 대기 중인 '기록 열기' 요청을 소비한다. 한 번 읽으면 플래그를 내린다.
  bool _shouldOpenStats() {
    if (TimerManager.instance.state.status != TimerStatus.idle) return false;
    if (!TimerManager.instance.openSettingsOnIdle) return false;
    TimerManager.instance.openSettingsOnIdle = false;
    return true;
  }

  @override
  void dispose() {
    TimerManager.instance.removeListenerToStatus(_onTimerStatusChanged);
    super.dispose();
  }

  void _onTimerStatusChanged(TimerStatus status) {
    // 오버레이가 이미 살아 있는 채로 idle이 된 경우(취소 등)를 위한 경로.
    if (!mounted || status != TimerStatus.idle) return;
    if (_shouldOpenStats()) setState(() => _isStatsOpen = true);
  }

  void _toggleStats() {
    setState(() => _isStatsOpen = !_isStatsOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _ShuttleWaveButton(
            onTap: () => TimerManager.instance.setFocus(),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 16,
          child: TdsGlassPanel(
            child: TdsIconButton(
              icon: const Icon(Icons.menu_rounded),
              size: TdsIconButtonSize.l,
              variant: TdsIconButtonVariant.clear,
              color: TdsColors.onCanvasIcon,
              semanticLabel: '메뉴',
              onPressed: _toggleStats,
            ),
          ),
        ),
        if (_isStatsOpen)
          FullScreenOverlay(
            onClose: _toggleStats,
            child: (context, close) => StatsScreen(onClose: close),
          ),
      ],
    );
  }
}

/// 집중을 시작하는 버튼. 파문이 계속 퍼져나가 시선을 붙든다.
class _ShuttleWaveButton extends StatefulWidget {
  const _ShuttleWaveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ShuttleWaveButton> createState() => _ShuttleWaveButtonState();
}

class _ShuttleWaveButtonState extends State<_ShuttleWaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (i) {
              final delay = i * 0.33;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = (_controller.value + delay) % 1.0;
                  final size = 60.0 + progress * 40.0;
                  final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.35;
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TdsColors.fillNeutral.withValues(alpha: opacity),
                    ),
                  );
                },
              );
            }),
            Image.asset(
              'assets/images/icons/shuttle.png',
              width: 32,
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}
