import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/features/data/datasources/focus_session_datasource.dart';
import 'package:catodo/features/data/models/focus_session_model.dart';
import 'package:catodo/features/data/repositories/focus_session_repository.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/views/overlays/focus_end_overlay.dart';
import 'package:catodo/theme/app_theme.dart';

import '../../support/test_stores.dart';

Future<void> _initRepository() async {
  final store = await loadedStore<FocusSession>(
    collection: 'focusSessions',
    toJson: (s) => s.toJson(),
    fromJson: FocusSession.fromJson,
    getId: (s) => s.id,
    setId: (s, id) => s.id = id,
  );
  FocusSessionRepository.initialize(FocusSessionDataSource(store));
}

void main() {
  setUpAll(_initRepository);

  group('FormManager.save', () {
    test('저장할 때마다 그 시점의 시각을 새로 찍는다', () async {
      FormManager.instance.updateActivity('영어 단어 외우기');

      final first = await FormManager.instance.save(120);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final second = await FormManager.instance.save(180);

      // 예전에는 매니저 생성 시각이 그대로 박혀서 두 값이 같았다.
      expect(second.date.isAfter(first.date), isTrue);
      expect(
        DateTime.now().difference(second.date).inSeconds,
        lessThan(5),
      );
    });

    test('저장된 세션에는 id가 채워진다', () async {
      final session = await FormManager.instance.save(60);
      expect(session.id, isNotNull);
    });
  });

  group('완료 화면', () {
    testWidgets('저장이 끝나면 요약 세 줄을 보여준다', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      FormManager.instance.updateActivity('수학 문제 풀기');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const FocusEndOverlay(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('기록에 저장했어요'), findsOneWidget);
      expect(find.text('집중한 일'), findsOneWidget);
      expect(find.text('집중한 시간'), findsOneWidget);
      expect(find.text('마친 시각'), findsOneWidget);
      expect(find.text('수학 문제 풀기'), findsOneWidget);
      expect(find.text('한 번 더 집중하기'), findsOneWidget);
      expect(find.text('기록 보기'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('활동 이름이 비어 있으면 대체 문구를 쓴다', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      FormManager.instance.updateActivity('');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const FocusEndOverlay(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('이름 없는 세션'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
