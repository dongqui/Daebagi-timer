import 'package:flutter/material.dart';

import 'package:catodo/core/utils/duration_format.dart';
import 'package:catodo/features/presentation/viewmodels/characater_state.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/overlays/settings/character_setting.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/tds/tds_button.dart';

/// 집중이 시작되기 직전의 숨 고르기 화면.
///
/// 캐릭터가 자리를 잡고, 무엇을 얼마나 할지 한 번 더 보여준 뒤 타이머로 넘어간다.
/// 게이지가 다 차면 저절로 시작하고, 기다리기 싫으면 바로 시작할 수도 있다.
///
/// 뒤로가기는 두지 않는다. 시작을 눌러 여기까지 온 상태라 되돌아갈 곳이 애매하고,
/// 오른쪽 위 토스 닫기와 성격이 겹친다.
class ReadyOverlay extends StatefulWidget {
  const ReadyOverlay({super.key});

  @override
  State<ReadyOverlay> createState() => _ReadyOverlayState();
}

class _ReadyOverlayState extends State<ReadyOverlay>
    with TickerProviderStateMixin {
  /// 게이지가 다 차는 데 걸리는 시간. 이만큼 지나면 저절로 시작한다.
  static const _dwell = Duration(milliseconds: 3200);

  /// 검은 배경이 걷히며 뒤의 타이머 월드가 드러나는 시간.
  static const _exit = Duration(milliseconds: 320);

  /// 등장 연출. 캐릭터 → 문구 → 칩 순으로 차례차례 들어온다.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1040),
  );

  late final AnimationController _gauge = AnimationController(
    vsync: this,
    duration: _dwell,
  );

  final _characterManager = CharacterManager.instance;
  late CharacterState _characterState = _characterManager.state;

  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _characterManager.addListener(_onCharacterChanged);

    _enter.forward();
    _gauge.forward().whenComplete(_leave);
  }

  @override
  void dispose() {
    _characterManager.removeListener(_onCharacterChanged);
    _enter.dispose();
    _gauge.dispose();
    super.dispose();
  }

  void _onCharacterChanged(CharacterState state, CharacterState? _) {
    if (mounted) setState(() => _characterState = state);
  }

  /// 배경을 걷고 타이머를 시작한다.
  ///
  /// 게이지가 다 차서 오든 사용자가 눌러서 오든 한 번만 실행돼야 한다.
  void _leave() {
    if (_leaving || !mounted) return;
    setState(() => _leaving = true);
    _gauge.stop();

    Future<void>.delayed(_exit, () {
      if (mounted) TimerManager.instance.start();
    });
  }

  String get _characterLabel =>
      _characterState.selectedCharacter?.label ?? '대박이';

  @override
  Widget build(BuildContext context) {
    final activity = FormManager.instance.state.activity.trim();
    final goalSeconds = TimerManager.instance.state.goalTime;

    return AnimatedOpacity(
      opacity: _leaving ? 0.0 : 1.0,
      duration: _exit,
      curve: Curves.easeOut,
      child: ColoredBox(
        color: TdsColors.canvas,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Staged(
                        parent: _enter,
                        begin: 0,
                        end: 900 / 1040,
                        curve: TdsMotion.emphasized,
                        rise: 22,
                        scaleFrom: 0.92,
                        child: const SizedBox(
                          width: 184,
                          height: 184,
                          child: CharacterSettingOverlay(
                            size: 184,
                            interactive: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _Staged(
                        parent: _enter,
                        begin: 200 / 1040,
                        end: 900 / 1040,
                        child: Column(
                          children: [
                            Text(
                              '$_characterLabel도 자리를 잡았어요',
                              style: TdsText.title.copyWith(fontSize: 22),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: TdsSpacing.gapM),
                            const Text(
                              '마음의 준비를 해볼까요?',
                              style: TextStyle(
                                fontSize: 15,
                                height: 22.5 / 15,
                                fontWeight: FontWeight.w500,
                                color: TdsColors.onCanvasLow,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _Staged(
                        parent: _enter,
                        begin: 340 / 1040,
                        end: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (activity.isNotEmpty) ...[
                              _ReadyChip(label: activity, maxWidth: 150),
                              const SizedBox(width: TdsSpacing.gapS),
                            ],
                            _ReadyChip(
                              label: formatHumanDuration(goalSeconds),
                              brand: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 34),
                child: Column(
                  children: [
                    _Gauge(progress: _gauge),
                    const SizedBox(height: 14),
                    TdsButton(
                      label: '지금 시작하기',
                      size: TdsButtonSize.xl,
                      fullWidth: true,
                      onPressed: _leave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 남은 시간을 채워 보여주는 가느다란 게이지.
class _Gauge extends StatelessWidget {
  const _Gauge({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 3,
        width: double.infinity,
        child: ColoredBox(
          color: TdsColors.fillNeutralWeak,
          child: AnimatedBuilder(
            animation: progress,
            builder: (context, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.value,
              child: const ColoredBox(color: TdsColors.brand),
            ),
          ),
        ),
      ),
    );
  }
}

/// 무엇을 얼마나 할지 알려주는 알약.
class _ReadyChip extends StatelessWidget {
  const _ReadyChip({
    required this.label,
    this.brand = false,
    this.maxWidth,
  });

  final String label;

  /// 브랜드 색으로 강조할지. 집중 시간처럼 눈에 먼저 들어와야 하는 값에 쓴다.
  final bool brand;

  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: brand ? TdsColors.brandWeak : TdsColors.fillNeutralWeak,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          height: 19.5 / 13,
          fontWeight: FontWeight.w600,
          color: brand ? TdsColors.brandWeakText : TdsColors.onCanvasHigh,
        ),
      ),
    );
  }
}

/// 하나의 등장 연출을 [parent]의 [begin]~[end] 구간에 얹는다.
///
/// 컨트롤러를 여러 개 두는 대신 구간을 나눠 쓴다 — 순서가 한눈에 보이고
/// 중간에 화면이 사라져도 정리할 게 하나뿐이다.
class _Staged extends StatelessWidget {
  const _Staged({
    required this.parent,
    required this.begin,
    required this.end,
    required this.child,
    this.curve = Curves.easeOut,
    this.rise = 0,
    this.scaleFrom = 1,
  });

  final Animation<double> parent;
  final double begin;
  final double end;
  final Curve curve;

  /// 아래에서 이만큼 떠오르며 들어온다.
  final double rise;

  /// 이 배율에서 시작해 원래 크기로 커진다.
  final double scaleFrom;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: parent,
      curve: Interval(begin, end, curve: curve),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, rise * (1 - t)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
