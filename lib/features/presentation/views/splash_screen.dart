import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:catodo/core/boot_screen.dart';
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

  /// 인트로 전체 길이. 화면이 처음 보이기 시작한 시점부터 잰다.
  ///
  /// 웹에서는 Dart가 뜨기 전에 `web/index.html`의 부트 화면이 같은 그림을 이미
  /// 보여주고 있다. 그래서 이 매니저가 마운트된 시점이 아니라 페이지를 연 시점을
  /// 기준으로 재야, 부팅이 빠르든 느리든 인트로 길이가 같게 느껴진다.
  static const _introTotal = Duration(milliseconds: 2000);

  /// Dart 인트로가 화면에 최소한 머무는 시간.
  ///
  /// 부팅이 오래 걸려 [_introTotal]을 이미 넘겼더라도, 넘겨받자마자 사라지면
  /// 크로스페이드가 끝나기도 전에 퇴장이 시작되어 어중간해 보인다.
  static const _minimumOnScreen = Duration(milliseconds: 700);

  Timer? _dwellTimer;
  bool _dwellElapsed = false;
  bool _handingOff = false;

  @override
  void initState() {
    super.initState();

    // 웹은 부트 화면이 이미 등장 연출을 마친 상태로 넘겨준다. 한 번 더 재생하면
    // 크로스페이드 도중에 캐릭터가 아래에서 다시 올라오며 튄다.
    if (kIsWeb) {
      _intro.value = 1;
    } else {
      _intro.forward();
    }

    final remaining = _introTotal - bootElapsed();
    _dwellTimer = Timer(
      remaining < _minimumOnScreen ? _minimumOnScreen : remaining,
      () {
        _dwellElapsed = true;
        _maybeHandoff();
      },
    );
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
        child: Stack(
          children: [
            Center(
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 80,
              child: FadeTransition(
                opacity: ReverseAnimation(handoffCurve),
                child: const Center(child: TdsLoader()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
