import 'dart:convert';

import 'package:catodo/features/data/models/audio_model.dart';
import 'package:catodo/features/data/models/character.dart';
import 'package:catodo/features/data/models/discovery.dart';
import 'package:catodo/features/data/models/focus_session_model.dart';
import 'package:catodo/features/data/models/latest-activity-model.dart';
import 'package:catodo/features/data/models/planet.dart';
import 'package:catodo/features/data/models/selected_character.dart';
import 'package:flutter_test/flutter_test.dart';

/// DocumentStore가 실제로 거치는 경로 그대로 왕복시킨다.
///
/// toJson 결과를 Map 그대로 fromJson에 넘기면 `List<int>`가 `List<int>`로 남아
/// 버그가 숨는다. jsonEncode/jsonDecode를 통과시켜야 `List<dynamic>`이 되어
/// 실제 저장/복원 시점의 동작을 재현할 수 있다.
T roundTrip<T>(Map<String, dynamic> Function() toJson,
    T Function(Map<String, dynamic>) fromJson) {
  final decoded = jsonDecode(jsonEncode(toJson())) as Map<String, dynamic>;
  return fromJson(decoded);
}

void main() {
  test('FocusSession은 id를 포함해 왕복한다', () {
    final original = FocusSession(
      activity: '공부',
      focusedTime: 1500,
      restTime: 300,
      date: DateTime(2026, 8, 11, 14, 30),
    )..id = 7;

    final restored = roundTrip(original.toJson, FocusSession.fromJson);

    expect(restored.id, 7);
    expect(restored.activity, '공부');
    expect(restored.focusedTime, 1500);
    expect(restored.restTime, 300);
    expect(restored.date, DateTime(2026, 8, 11, 14, 30));
  });

  test('Character는 프레임 리스트를 int 리스트로 복원한다', () {
    final original = Character(
      id: 3,
      name: 'dog_white',
      travelframes: [0, 1, 2, 3],
      travelSprite: 'characters/dog_white_travel.png',
      idleSprite: 'characters/dog_white_idle.png',
      idleFrames: [0],
      isPremium: true,
    );

    final restored = roundTrip(original.toJson, Character.fromJson);

    expect(restored.id, 3);
    expect(restored.name, 'dog_white');
    expect(restored.travelframes, [0, 1, 2, 3]);
    expect(restored.idleFrames, [0]);
    expect(restored.travelSprite, 'characters/dog_white_travel.png');
    expect(restored.idleSprite, 'characters/dog_white_idle.png');
    expect(restored.isPremium, isTrue);
  });

  test('기본 캐릭터 시드 데이터도 왕복한다', () {
    for (final character in defaultCharacters) {
      final restored = roundTrip(character.toJson, Character.fromJson);

      expect(restored.id, character.id);
      expect(restored.travelframes, character.travelframes);
      expect(restored.idleFrames, character.idleFrames);
    }
  });

  test('Planet은 id를 포함해 왕복한다', () {
    final original =
        Planet(id: 5, name: '토성', url: 'planets/saturn.png', isPremium: false);

    final restored = roundTrip(original.toJson, Planet.fromJson);

    expect(restored.id, 5);
    expect(restored.name, '토성');
    expect(restored.url, 'planets/saturn.png');
    expect(restored.isPremium, isFalse);
  });

  test('Discovery는 sessionIds를 int 리스트로 복원한다', () {
    final original = Discovery(
      id: 2,
      sessionIds: [10, 11, 12],
      planetId: 3,
      isFinished: true,
    );

    final restored = roundTrip(original.toJson, Discovery.fromJson);

    expect(restored.id, 2);
    expect(restored.sessionIds, [10, 11, 12]);
    expect(restored.planetId, 3);
    expect(restored.isFinished, isTrue);
  });

  test('Discovery의 sessionIds는 복원 후에도 추가할 수 있다', () {
    final original =
        Discovery(id: 1, sessionIds: [], planetId: 1, isFinished: false);

    final restored = roundTrip(original.toJson, Discovery.fromJson);
    restored.sessionIds.add(99);

    expect(restored.sessionIds, [99]);
  });

  test('Audio는 whiteNoise를 String 리스트로 복원한다', () {
    final original = Audio(
      whiteNoise: ['rain', 'wave'],
      currentMusic: 'lofi',
      isMusicOn: false,
    )..id = 1;

    final restored = roundTrip(original.toJson, Audio.fromJson);

    expect(restored.id, 1);
    expect(restored.whiteNoise, ['rain', 'wave']);
    expect(restored.currentMusic, 'lofi');
    expect(restored.isMusicOn, isFalse);
  });

  test('SelectedCharacter는 id를 포함해 왕복한다', () {
    final original = SelectedCharacter(name: 'astronaut')..id = 4;

    final restored = roundTrip(original.toJson, SelectedCharacter.fromJson);

    expect(restored.id, 4);
    expect(restored.name, 'astronaut');
  });

  test('LatestActivity는 hasDeleted를 보존한다', () {
    final original = LatestActivity(
      name: '독서',
      timestamp: DateTime(2026, 8, 1, 9),
    )
      ..id = 6
      ..hasDeleted = true;

    final restored = roundTrip(original.toJson, LatestActivity.fromJson);

    expect(restored.id, 6);
    expect(restored.name, '독서');
    expect(restored.timestamp, DateTime(2026, 8, 1, 9));
    expect(restored.hasDeleted, isTrue);
  });
}
