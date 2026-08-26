import 'package:flutter/widgets.dart';

/// 오버레이 뒤에 까는 정적 우주 배경.
///
/// Flame 월드는 타이머 상태에 따라 홈/타이머 중 무엇이 떠 있는지가 달라져서
/// 화면마다 배경이 들쭉날쭉하다. 집중 폼과 완료 화면은 배경이 결정적이어야 하므로
/// 게임에 기대지 않고 같은 별 에셋으로 직접 그린다.
///
/// 별 레이어는 `SpaceMap`이 쓰는 것과 같은 parallax PNG 3장이다. 투명 배경에
/// 별만 찍혀 있어서 어두운 그라디언트 위에 겹쳐 쌓으면 밀도가 생긴다.
class SpaceBackdrop extends StatelessWidget {
  const SpaceBackdrop({
    super.key,
    this.moon = false,
    this.moonAlignment = const Alignment(1.15, 0.75),
    this.moonScale = 0.62,
    this.child,
  });

  /// 달을 함께 그릴지. 화면 밖으로 살짝 잘려 나가게 배치된다.
  final bool moon;
  final Alignment moonAlignment;

  /// 달 지름을 배경 너비 대비 비율로 지정한다.
  final double moonScale;

  final Widget? child;

  static const _layers = [
    // (에셋, 정렬, 불투명도) — 같은 이미지를 다르게 앉혀 별이 겹쳐 보이지 않게 한다.
    ('assets/images/parallax/stars_bot.png', Alignment.bottomCenter, 0.55),
    ('assets/images/parallax/stars_mid.png', Alignment.center, 0.75),
    ('assets/images/parallax/stars_top.png', Alignment.topLeft, 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        // 별 레이어 원본은 2752x2064다. 그대로 디코딩하면 장당 20MB가 넘는
        // 비트맵이 세 개 뜨므로, 화면 폭에 맞춰 줄여서 읽는다.
        final decodeWidth =
            (width * MediaQuery.devicePixelRatioOf(context)).round();

        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.35),
                  radius: 1.1,
                  colors: [Color(0xFF14141C), Color(0xFF000000)],
                ),
              ),
            ),
            for (final (asset, alignment, opacity) in _layers)
              Opacity(
                opacity: opacity,
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  alignment: alignment,
                  cacheWidth: decodeWidth,
                  filterQuality: FilterQuality.low,
                  excludeFromSemantics: true,
                ),
              ),
            if (moon)
              Align(
                alignment: moonAlignment,
                child: Image.asset(
                  'assets/images/planet.png',
                  width: width * moonScale,
                  filterQuality: FilterQuality.medium,
                  excludeFromSemantics: true,
                ),
              ),
            if (child != null) child!,
          ],
        );
      },
    );
  }
}
