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
