import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_typography.dart';

/// 집중이 시작되기 직전의 숨 고르기 화면.
///
/// 글자가 한 자씩 사라지고 배경이 걷히면서 뒤의 타이머 월드가 드러난다.
class ReadyOverlay extends StatefulWidget {
  const ReadyOverlay({super.key});

  @override
  State<ReadyOverlay> createState() => _ReadyOverlayState();
}

class _ReadyOverlayState extends State<ReadyOverlay> {
  static const _message = '곧 집중이 시작돼요!\n마음의 준비를 해볼까요?';
  static const _holdBeforeFade = Duration(milliseconds: 1000);
  static const _fadeOutTotal = Duration(milliseconds: 2000);
  static const _perCharFade = Duration(milliseconds: 200);
  static const _backdropFade = Duration(milliseconds: 400);

  late final List<double> _charOpacities =
      List.filled(_message.length, 1.0, growable: false);

  final List<Timer> _timers = [];
  double _backdropOpacity = 1.0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _scheduleFadeOut();
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  /// 글자를 하나씩 지운 뒤 배경을 걷고 타이머를 시작한다.
  ///
  /// `Future.delayed` 대신 취소 가능한 타이머를 쓴다 — 중간에 화면이 사라져도
  /// 예약된 동작이 남아 타이머를 시작해버리는 일이 없어야 한다.
  void _scheduleFadeOut() {
    final perChar = _fadeOutTotal ~/ _message.length;

    for (var i = 0; i < _message.length; i++) {
      _schedule(_holdBeforeFade + perChar * (i + 1), () {
        setState(() => _charOpacities[i] = 0.0);
      });
    }

    final allGone = _holdBeforeFade + _fadeOutTotal;
    _schedule(allGone + const Duration(milliseconds: 200), () {
      setState(() => _backdropOpacity = 0.0);
    });
    _schedule(allGone + const Duration(milliseconds: 600), _startFocus);
  }

  void _schedule(Duration delay, VoidCallback action) {
    _timers.add(Timer(delay, () {
      if (mounted) action();
    }));
  }

  void _startFocus() {
    if (_started) return;
    _started = true;
    TimerManager.instance.start();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _backdropOpacity,
          duration: _backdropFade,
          child: const ColoredBox(
            color: TdsColors.canvas,
            child: SizedBox.expand(),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < _message.length; i++)
                  if (_message[i] == '\n')
                    const SizedBox(width: double.infinity, height: 16)
                  else
                    AnimatedOpacity(
                      opacity: _charOpacities[i],
                      duration: _perCharFade,
                      child: Text(
                        _message[i],
                        style: TdsText.title.copyWith(
                          color: TdsColors.onCanvasStrong,
                          height: 1.4,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
