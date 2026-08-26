import 'dart:async';

import 'package:flutter/material.dart';

import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/space_backdrop.dart';
import 'package:catodo/widgets/tds/tds_loader.dart';

/// 앱을 여는 인트로.
///
/// 캐릭터가 떠오르며 나타났다가, 초기화가 끝나면 홈으로 내려앉으며 사라진다.
/// [isReady]가 켜지고 최소 노출 시간이 지나야 [onFinished]를 부른다 —
/// 초기화가 순식간에 끝나도 화면이 깜빡이고 마는 걸 막는다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.isReady = false,
    this.onFinished,
  });

  final bool isReady;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// 캐릭터가 떠오르며 등장.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  /// 홈으로 넘겨주는 퇴장.
  late final AnimationController _handoff = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  /// 인트로를 최소한 이만큼은 보여준다.
  ///
  /// 토스 미니앱에서는 이 화면이 앱의 첫인상이자 캐릭터를 소개하는 자리다.
  /// 초기화가 순식간에 끝나더라도 스쳐 지나가면 안 된다.
  ///
  /// `web/index.html`의 부트 화면은 토스 자체 로딩 화면에 가려 보이지 않으므로
  /// 계산에 넣지 않는다. 여기서 세는 시간이 사용자가 실제로 보는 시간이다.
  static const _minimumDwell = Duration(seconds: 2);

  Timer? _dwellTimer;
  bool _dwellElapsed = false;
  bool _handingOff = false;

  @override
  void initState() {
    super.initState();

    _intro.forward();
    _dwellTimer = Timer(_minimumDwell, () {
      _dwellElapsed = true;
      _maybeHandoff();
    });
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady && !oldWidget.isReady) _maybeHandoff();
  }

  @override
  void dispose() {
    _dwellTimer?.cancel();
    _intro.dispose();
    _handoff.dispose();
    super.dispose();
  }

  void _maybeHandoff() {
    if (_handingOff || !_dwellElapsed || !widget.isReady) return;
    _handingOff = true;
    _handoff.forward().whenComplete(() => widget.onFinished?.call());
  }

  @override
  Widget build(BuildContext context) {
    final introCurve = CurvedAnimation(
      parent: _intro,
      curve: TdsMotion.emphasized,
    );
    final handoffCurve = CurvedAnimation(
      parent: _handoff,
      curve: TdsMotion.emphasized,
    );

    return Scaffold(
      backgroundColor: TdsColors.canvas,
      // 게임 월드와 같은 별 에셋을 깔아 인트로부터 우주로 이어지게 한다.
      // 검정 배경에서는 캐릭터가 허공에 뜬 것처럼 보였다.
      body: SpaceBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                          child: AnimatedBuilder(
                        animation: Listenable.merge([introCurve, handoffCurve]),
                        builder: (context, child) {
                          final intro = introCurve.value;
                          final exit = handoffCurve.value;
                          return Opacity(
                            opacity: intro * (1 - exit),
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1 - intro) + 168 * exit),
                              child: Transform.scale(
                                scale: (0.94 + 0.06 * intro) * (1 - 0.76 * exit),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/dog_cutout.webp',
                          width: 210,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                      )),
                      const SizedBox(height: 26),
                      AnimatedBuilder(
                        animation: Listenable.merge([introCurve, _handoff]),
                        builder: (context, child) {
                          // 글자는 캐릭터보다 빨리 빠진다 (300ms / 700ms).
                          final exit =
                              (_handoff.value / (300 / 700)).clamp(0.0, 1.0);
                          return Opacity(
                            opacity: introCurve.value * (1 - exit),
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1 - introCurve.value)),
                              child: child,
                            ),
                          );
                        },
                        child: const Column(
                          children: [
                            Text('대박이 타이머', style: TdsText.title),
                            SizedBox(height: TdsSpacing.gapM),
                            Text(
                              '대박이와 함께 집중해요',
                              style: TextStyle(
                                fontSize: 15,
                                height: 22.5 / 15,
                                color: TdsColors.onCanvasLow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 로더는 레이아웃 흐름 안에 둔다. 화면 아래에 절대 배치했더니
              // 캐릭터가 큰 화면에서 문구를 밀어 내려 로더와 겹쳤다.
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 48),
                child: FadeTransition(
                  opacity: ReverseAnimation(handoffCurve),
                  child: const TdsLoader(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
