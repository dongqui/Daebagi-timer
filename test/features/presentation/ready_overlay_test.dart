import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/features/data/datasources/chacater-datasource.dart';
import 'package:catodo/features/data/datasources/selected_character_datasource.dart';
import 'package:catodo/features/data/models/character.dart';
import 'package:catodo/features/data/models/selected_character.dart';
import 'package:catodo/features/data/repositories/character_repository.dart';
import 'package:catodo/features/data/repositories/selected_character_repository.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/overlays/ready_overlay.dart';
import 'package:catodo/theme/app_theme.dart';

import '../../support/test_stores.dart';

Future<void> _initRepositories() async {
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

Future<void> _pumpReady(WidgetTester tester) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: const Scaffold(body: ReadyOverlay()),
    ),
  );
  // 캐릭터 스프라이트가 무한 루프라 pumpAndSettle은 영영 끝나지 않는다.
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

/// 준비 화면이 끝나면 TimerManager가 1초 주기 타이머를 돌린다.
/// 테스트가 끝나기 전에 세워두지 않으면 "타이머가 남아 있다"로 실패한다.
void _stopTimer() {
  if (TimerManager.instance.state.status == TimerStatus.running) {
    TimerManager.instance.pause();
  }
}

void main() {
  setUpAll(_initRepositories);

  setUp(() {
    FormManager.instance.updateActivity('영어 단어 외우기');
    TimerManager.instance.updateGoalTime(1500);
    TimerManager.instance.readyToFocus();
  });

  tearDown(_stopTimer);

  group('준비 화면', () {
    testWidgets('캐릭터 이름과 세운 계획을 보여준다', (tester) async {
      await _pumpReady(tester);

      expect(find.text('대박이도 자리를 잡았어요'), findsOneWidget);
      expect(find.text('마음의 준비를 해볼까요?'), findsOneWidget);
      expect(find.text('영어 단어 외우기'), findsOneWidget);
      expect(find.text('25분'), findsOneWidget);
      expect(find.text('지금 시작하기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('뒤로가기를 두지 않는다', (tester) async {
      // 오른쪽 위 토스 닫기와 성격이 겹치고, 되돌아갈 곳도 애매하다.
      await _pumpReady(tester);

      expect(find.bySemanticsLabel('뒤로'), findsNothing);
    });

    testWidgets('할 일을 안 적었으면 시간만 보여준다', (tester) async {
      FormManager.instance.updateActivity('   ');
      await _pumpReady(tester);

      expect(find.text('25분'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('게이지가 다 차면 저절로 시작한다', (tester) async {
      await _pumpReady(tester);
      expect(TimerManager.instance.state.status, TimerStatus.ready);

      await tester.pump(const Duration(milliseconds: 3200));
      await tester.pump(const Duration(milliseconds: 400));

      // 주기 타이머는 테스트 본문 안에서 세워야 한다. 남은 타이머 검사가
      // tearDown보다 먼저 돈다.
      final status = TimerManager.instance.state.status;
      _stopTimer();
      expect(status, TimerStatus.running);
    });

    testWidgets('지금 시작하기를 누르면 기다리지 않는다', (tester) async {
      await _pumpReady(tester);

      await tester.tap(find.text('지금 시작하기'));
      await tester.pump(const Duration(milliseconds: 400));

      final status = TimerManager.instance.state.status;
      _stopTimer();
      expect(status, TimerStatus.running);
    });
  });
}
