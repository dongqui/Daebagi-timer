import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/features/data/datasources/chacater-datasource.dart';
import 'package:catodo/features/data/datasources/focus_session_datasource.dart';
import 'package:catodo/features/data/datasources/selected_character_datasource.dart';
import 'package:catodo/features/data/models/character.dart';
import 'package:catodo/features/data/models/focus_session_model.dart';
import 'package:catodo/features/data/models/selected_character.dart';
import 'package:catodo/features/data/repositories/character_repository.dart';
import 'package:catodo/features/data/repositories/focus_session_repository.dart';
import 'package:catodo/features/data/repositories/selected_character_repository.dart';
import 'package:catodo/features/presentation/viewmodels/chart_state.dart';
import 'package:catodo/features/presentation/views/stats/stats_screen.dart';
import 'package:catodo/theme/app_theme.dart';
import 'package:catodo/widgets/tds/tds_navigation.dart';

import '../../support/test_stores.dart';

Future<void> _initRepositories() async {
  FocusSessionRepository.initialize(
    FocusSessionDataSource(
      await loadedStore<FocusSession>(
        collection: 'focusSessions',
        toJson: (s) => s.toJson(),
        fromJson: FocusSession.fromJson,
        getId: (s) => s.id,
        setId: (s, id) => s.id = id,
      ),
    ),
  );

  final characterStore = await loadedStore<Character>(
    collection: 'characters',
    toJson: (c) => c.toJson(),
    fromJson: Character.fromJson,
    getId: (c) => c.id,
    setId: (c, id) => c.id = id,
  );
  CharacterRepository.initialize(CharacterDataSource(characterStore));
  await CharacterRepository.instance.initializeDefaultCharacters();

  SelectedCharacterRepository.initialize(
    SelectedCharacterDataSource(
      await loadedStore<SelectedCharacter>(
        collection: 'selectedCharacter',
        toJson: (s) => s.toJson(),
        fromJson: SelectedCharacter.fromJson,
        getId: (s) => s.id,
        setId: (s, id) => s.id = id,
      ),
    ),
  );
  await SelectedCharacterRepository.instance
      .initSelectedCharacter(defaultCharacters[0].name);
}

Future<void> _pumpStats(WidgetTester tester, {VoidCallback? onClose}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: StatsScreen(onClose: onClose ?? () {}),
    ),
  );
  // 캐릭터 스프라이트가 무한 루프라 pumpAndSettle은 영영 끝나지 않는다.
  // 비동기 초기화(저장소 조회, 스프라이트 로드)가 끝날 만큼만 프레임을 돌린다.
  await _settleAsync(tester);
}

Future<void> _settleAsync(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  setUpAll(_initRepositories);

  group('기록 화면', () {
    testWidgets('기록이 없으면 빈 상태와 0 요약을 보여준다', (tester) async {
      await _pumpStats(tester);

      expect(find.text('아직 기록이 없어요'), findsOneWidget);
      expect(find.text('집중을 시작하면 여기에 쌓여요'), findsOneWidget);
      expect(find.text('총 집중 시간'), findsOneWidget);
      expect(find.text('0초'), findsOneWidget);
      expect(find.text('0회'), findsOneWidget);

      // 375x812에서 넘치는 요소가 없어야 한다.
      expect(tester.takeException(), isNull);
    });

    testWidgets('상단 버튼이 토스 네비게이션 바 자리를 비켜 있다', (tester) async {
      // 오른쪽 위는 앱인토스가 더보기(...)·닫기(X)를 그리는 자리다. 미니앱이 끌
      // 수 없어서, 우리 버튼이 거기 있으면 둘이 위아래로 겹쳐 보인다.
      await _pumpStats(tester);

      final nav = tester.getRect(find.byType(TdsNavigation));

      // 내비게이션 줄에 남는 건 닫기뿐이고, 그마저 왼쪽에 붙어 있다.
      expect(tester.getRect(find.bySemanticsLabel('닫기')).right,
          lessThan(375 / 2));

      // 꾸미기는 오른쪽이지만 내비게이션 줄 아래(캐릭터 자리)로 내려가 있다.
      expect(
        tester.getRect(find.bySemanticsLabel('캐릭터 꾸미기')).top,
        greaterThanOrEqualTo(nav.bottom),
        reason: '꾸미기 칩은 토스 네비게이션 바 줄 아래에 있어야 한다',
      );
    });

    testWidgets('일/주/월/년을 모두 골라도 레이아웃이 버틴다', (tester) async {
      await _pumpStats(tester);

      for (final label in ['일', '월', '년', '주']) {
        await tester.tap(find.text(label));
        await _settleAsync(tester);
        expect(tester.takeException(), isNull, reason: '$label 단위에서 예외');
      }

      expect(ChartManager.instance.state.currentDateUnit, DateUnit.week);
    });

    testWidgets('기간 이동 버튼이 선택된 날짜를 바꾼다', (tester) async {
      await _pumpStats(tester);
      final before = ChartManager.instance.state.selectedDate;

      await tester.tap(find.bySemanticsLabel('이전').first);
      await _settleAsync(tester);

      expect(
        ChartManager.instance.state.selectedDate.isBefore(before),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('닫기 버튼은 onClose를 부른다', (tester) async {
      var closed = false;
      await _pumpStats(tester, onClose: () => closed = true);

      await tester.tap(find.bySemanticsLabel('닫기').first);
      await _settleAsync(tester);

      expect(closed, isTrue);
    });
  });
}
