import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/features/data/datasources/latest-activity-datasource.dart';
import 'package:catodo/features/data/models/latest-activity-model.dart';
import 'package:catodo/features/data/repositories/latest_activity_repository.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/overlays/focus_form_overlay.dart';
import 'package:catodo/theme/app_theme.dart';
import 'package:catodo/widgets/tds/tds_button.dart';
import 'package:catodo/widgets/tds/tds_numeric_spinner.dart';

import '../../support/test_stores.dart';

Future<void> _initRepositories() async {
  LatestActivityRepository.initialize(
    LatestActivityDataSource(
      await loadedStore<LatestActivity>(
        collection: 'latestActivities',
        toJson: (a) => a.toJson(),
        fromJson: LatestActivity.fromJson,
        getId: (a) => a.id,
        setId: (a, id) => a.id = id,
      ),
    ),
  );
}

Future<void> _pumpForm(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: FocusFormOverlay()),
    ),
  );
  await tester.pumpAndSettle();
}

/// 스피너 안의 탭 대상 순서: 감소 버튼, 숫자 칸, 증가 버튼.
const _decrease = 0;
const _numberField = 1;
const _increase = 2;

Finder _spinnerPart(int spinnerIndex, int part) => find
    .descendant(
      of: find.byType(TdsNumericSpinner).at(spinnerIndex),
      matching: find.byType(GestureDetector),
    )
    .at(part);

void main() {
  setUpAll(_initRepositories);

  setUp(() {
    // 매니저가 싱글턴이라 테스트끼리 값이 새지 않게 되돌려 둔다.
    FormManager.instance.updateActivity('');
    FormManager.instance.updateDuration(25 * 60);
    TimerManager.instance.cancel();
  });

  group('집중 준비 화면', () {
    testWidgets('시/분/초 스피너와 시작 버튼이 한 화면에 들어간다', (tester) async {
      await _pumpForm(tester);

      expect(find.text('어떤 일에 집중하실 건가요?'), findsOneWidget);
      expect(find.text('얼마나 집중하실 건가요?'), findsOneWidget);
      expect(find.text('시간'), findsOneWidget);
      expect(find.text('분'), findsOneWidget);
      expect(find.text('초'), findsOneWidget);
      expect(find.byType(TdsNumericSpinner), findsNWidgets(3));
      expect(find.text('시작하기'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('기본값 25분이 합계 라벨에 나온다', (tester) async {
      await _pumpForm(tester);
      expect(find.text('총 25분 집중'), findsOneWidget);
    });

    testWidgets('전부 0으로 내리면 시작 버튼이 잠긴다', (tester) async {
      await _pumpForm(tester);

      for (var i = 0; i < 25; i++) {
        await tester.tap(_spinnerPart(1, _decrease));
        await tester.pump();
      }

      expect(FormManager.instance.state.duration, 0);
      expect(find.text('시간을 골라주세요'), findsOneWidget);

      final button = tester.widget<TdsButton>(find.byType(TdsButton));
      expect(button.onPressed, isNull, reason: '0초는 시작할 수 없어야 한다');
    });

    testWidgets('스피너를 올리면 합계가 따라 오른다', (tester) async {
      await _pumpForm(tester);

      await tester.tap(_spinnerPart(0, _increase)); // 시간 +1
      await tester.pump();

      expect(FormManager.instance.state.duration, 3600 + 25 * 60);
      expect(find.text('총 1시간 25분 집중'), findsOneWidget);
    });

    testWidgets('숫자를 눌러 직접 입력할 수 있다', (tester) async {
      await _pumpForm(tester);

      await tester.tap(_spinnerPart(1, _numberField)); // 분
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '45');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(FormManager.instance.state.duration, 45 * 60);
      expect(find.text('총 45분 집중'), findsOneWidget);
    });

    testWidgets('직접 입력한 값도 max를 넘지 않는다', (tester) async {
      await _pumpForm(tester);

      await tester.tap(_spinnerPart(0, _numberField)); // 시간 (max 12)
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '99');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(FormManager.instance.state.duration, 12 * 3600 + 25 * 60);
    });

    testWidgets('시작하면 타이머가 준비 상태로 넘어간다', (tester) async {
      await _pumpForm(tester);

      await tester.tap(find.text('시작하기'));
      await tester.pump();

      expect(TimerManager.instance.state.status, TimerStatus.ready);
      expect(TimerManager.instance.state.goalTime, 25 * 60);
    });
  });
}
