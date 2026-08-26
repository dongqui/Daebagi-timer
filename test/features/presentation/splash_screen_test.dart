import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/features/presentation/views/splash_screen.dart';
import 'package:catodo/theme/app_theme.dart';
import 'package:catodo/widgets/tds/tds_loader.dart';

/// [isReady]를 바꿔가며 다시 그릴 수 있게 감싼 껍데기.
class _Host extends StatefulWidget {
  const _Host({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool _ready = false;

  void markReady() => setState(() => _ready = true);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: SplashScreen(isReady: _ready, onFinished: widget.onFinished),
    );
  }
}

Future<_HostState> _pumpSplash(
  WidgetTester tester, {
  required VoidCallback onFinished,
  Size size = const Size(375, 812),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_Host(onFinished: onFinished));
  await tester.pump(const Duration(milliseconds: 700));
  return tester.state<_HostState>(find.byType(_Host));
}

/// 캐릭터 이미지를 실제로 디코딩시킨 뒤 인트로를 그린다.
///
/// 이미지가 안 잡히면 캐릭터 높이가 0이 되어, 캐릭터가 문구를 밀어 내려
/// 로더와 겹치던 문제를 재현할 수 없다.
Future<void> _pumpSplashWithImage(
  WidgetTester tester, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.runAsync(() async {
    await tester.pumpWidget(_Host(onFinished: () {}));
    await precacheImage(
      const AssetImage('assets/images/dog_cutout.webp'),
      tester.element(find.byType(SplashScreen)),
    );
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  group('인트로 화면', () {
    testWidgets('브랜드 문구와 로더를 보여준다', (tester) async {
      await _pumpSplash(tester, onFinished: () {});

      expect(find.text('대박이 타이머'), findsOneWidget);
      expect(find.text('대박이와 함께 집중해요'), findsOneWidget);
      expect(find.byType(TdsLoader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('작은 화면에서도 넘치지 않는다', (tester) async {
      // iPhone SE 크기. 캐릭터가 세로로 길어 여기서 가장 아슬아슬하다.
      await _pumpSplash(
        tester,
        onFinished: () {},
        size: const Size(320, 568),
      );

      expect(tester.takeException(), isNull);
    });

    for (final size in const [
      Size(375, 812), // iPhone 13
      Size(320, 568), // iPhone SE
      Size(412, 915), // Galaxy S
    ]) {
      testWidgets('${size.width.toInt()}x${size.height.toInt()}에서 로더가 문구를 가리지 않는다',
          (tester) async {
        await _pumpSplashWithImage(tester, size: size);

        final subtitle = tester.getRect(find.text('대박이와 함께 집중해요'));
        final loader = tester.getRect(find.byType(TdsLoader));

        expect(
          loader.top,
          greaterThanOrEqualTo(subtitle.bottom),
          reason: '로더는 문구 아래에 떨어져 있어야 한다',
        );
        expect(loader.bottom, lessThanOrEqualTo(size.height));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('초기화가 끝나도 최소 노출 시간 전에는 넘어가지 않는다', (tester) async {
      var finished = false;
      final host = await _pumpSplash(tester, onFinished: () => finished = true);

      host.markReady();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(finished, isFalse, reason: '최소 노출 시간 전에는 인트로가 유지돼야 한다');

      // 최소 노출 시간 + 퇴장 연출까지 넉넉히 흘려보낸다.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump(const Duration(milliseconds: 800));

      expect(finished, isTrue);
    });

    testWidgets('초기화가 안 끝나면 계속 기다린다', (tester) async {
      var finished = false;
      await _pumpSplash(tester, onFinished: () => finished = true);

      await tester.pump(const Duration(seconds: 5));

      expect(finished, isFalse);
      expect(find.text('대박이 타이머'), findsOneWidget);
    });
  });
}
