import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:catodo/core/storage/document_store.dart';
import 'package:catodo/core/storage/key_value_store.dart';
import 'package:catodo/core/storage/shared_preferences_store.dart';
import 'package:catodo/features/data/datasources/audio_datasource.dart';
import 'package:catodo/features/data/datasources/chacater-datasource.dart';
import 'package:catodo/features/data/datasources/focus_session_datasource.dart';
import 'package:catodo/features/data/datasources/latest-activity-datasource.dart';
import 'package:catodo/features/data/datasources/selected_character_datasource.dart';
import 'package:catodo/features/data/models/audio_model.dart';
import 'package:catodo/features/data/models/character.dart';
import 'package:catodo/features/data/models/focus_session_model.dart';
import 'package:catodo/features/data/models/latest-activity-model.dart';
import 'package:catodo/features/data/models/selected_character.dart';
import 'package:catodo/features/presentation/viewmodels/chart_state.dart';

/// 앱을 껐다 켜도 데이터가 남는지 확인한다.
///
/// 인메모리 대역이 아니라 실제 기본 백엔드(`shared_preferences`)를 쓰고,
/// "재시작"은 저장소 객체를 전부 새로 만들고 플랫폼에서 다시 읽어오는 것으로
/// 흉내낸다. 컬렉션 이름은 `lib/core/db.dart`의 `setUpDB()`와 같은 값을 쓴다 —
/// 이름이 어긋나면 실제로는 데이터를 못 찾는데 테스트만 통과하기 때문이다.
class _Collections {
  static const focusSessions = 'focusSessions';
  static const latestActivities = 'latestActivities';
  static const audios = 'audios';
  static const characters = 'characters';
  static const selectedCharacters = 'selectedCharacters';
}

/// 앱 한 번의 실행. 매번 새 인스턴스를 만들어 재시작을 흉내낸다.
class _AppSession {
  _AppSession._(this.backend);

  final KeyValueStore backend;

  late final DocumentStore<FocusSession> focusSessions;
  late final DocumentStore<LatestActivity> latestActivities;
  late final DocumentStore<Audio> audios;
  late final DocumentStore<Character> characters;
  late final DocumentStore<SelectedCharacter> selectedCharacters;

  static Future<_AppSession> start() async {
    // 플랫폼에서 다시 읽어오게 해서, 메모리에 남은 캐시를 보고 통과하는 걸 막는다.
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final backend = SharedPreferencesStore();
    await backend.init();

    final session = _AppSession._(backend);
    session.focusSessions = DocumentStore<FocusSession>(
      backend: backend,
      collection: _Collections.focusSessions,
      toJson: (item) => item.toJson(),
      fromJson: FocusSession.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    session.latestActivities = DocumentStore<LatestActivity>(
      backend: backend,
      collection: _Collections.latestActivities,
      toJson: (item) => item.toJson(),
      fromJson: LatestActivity.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    session.audios = DocumentStore<Audio>(
      backend: backend,
      collection: _Collections.audios,
      toJson: (item) => item.toJson(),
      fromJson: Audio.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    session.characters = DocumentStore<Character>(
      backend: backend,
      collection: _Collections.characters,
      toJson: (item) => item.toJson(),
      fromJson: Character.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    session.selectedCharacters = DocumentStore<SelectedCharacter>(
      backend: backend,
      collection: _Collections.selectedCharacters,
      toJson: (item) => item.toJson(),
      fromJson: SelectedCharacter.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );

    await Future.wait([
      session.focusSessions.load(),
      session.latestActivities.load(),
      session.audios.load(),
      session.characters.load(),
      session.selectedCharacters.load(),
    ]);
    return session;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('집중 기록은 재시작 후에도 남는다', () async {
    final first = await _AppSession.start();
    final source = FocusSessionDataSource(first.focusSessions);
    await source.addFocusSession(FocusSession(
      activity: '영어 단어 외우기',
      focusedTime: 1500,
      restTime: 0,
      date: DateTime(2026, 8, 26, 15, 24),
    ));

    final restarted = await _AppSession.start();
    final saved =
        await FocusSessionDataSource(restarted.focusSessions).getFocusSessions();

    expect(saved, hasLength(1));
    expect(saved.single.activity, '영어 단어 외우기');
    expect(saved.single.focusedTime, 1500);
    expect(saved.single.date, DateTime(2026, 8, 26, 15, 24));
  });

  test('여러 번 껐다 켜도 기록이 누적된다', () async {
    for (var day = 1; day <= 3; day++) {
      final session = await _AppSession.start();
      await FocusSessionDataSource(session.focusSessions).addFocusSession(
        FocusSession(
          activity: '$day일차',
          focusedTime: 600 * day,
          restTime: 0,
          date: DateTime(2026, 8, day),
        ),
      );
    }

    final restarted = await _AppSession.start();
    final saved =
        await FocusSessionDataSource(restarted.focusSessions).getFocusSessions();

    expect(saved.map((s) => s.activity), ['1일차', '2일차', '3일차']);
    expect(saved.map((s) => s.id), [1, 2, 3], reason: 'id가 이어서 부여돼야 한다');
  });

  test('기간별 차트 조회도 재시작 후 그대로 동작한다', () async {
    final first = await _AppSession.start();
    final source = FocusSessionDataSource(first.focusSessions);
    await source.addFocusSession(FocusSession(
      activity: '수학',
      focusedTime: 1200,
      restTime: 0,
      date: DateTime(2026, 8, 26, 10),
    ));

    final restarted = await _AppSession.start();
    final buckets = await FocusSessionDataSource(restarted.focusSessions)
        .getFocusSessionsByDateRange(DateUnit.day, DateTime(2026, 8, 26));

    final total = buckets
        .expand((series) => series)
        .fold<int>(0, (sum, tuple) => sum + tuple.$2);
    expect(total, 1200);
  });

  test('최근 활동 목록은 재시작 후에도 남는다', () async {
    final first = await _AppSession.start();
    await LatestActivityDataSource(first.latestActivities).addActivity(
      LatestActivity(name: '영어 단어 외우기', timestamp: DateTime(2026, 8, 26)),
    );

    final restarted = await _AppSession.start();
    final saved = await LatestActivityDataSource(restarted.latestActivities)
        .getLatestActivities();

    expect(saved.map((a) => a.name), contains('영어 단어 외우기'));
  });

  test('백색소음 선택은 재시작 후에도 남는다', () async {
    final first = await _AppSession.start();
    final source = AudioDataSource(first.audios);
    final audio = await source.getOrCreateAudio();
    audio.whiteNoise = ['rain'];
    await source.updateAudio(audio);

    final restarted = await _AppSession.start();
    final saved = await AudioDataSource(restarted.audios).getOrCreateAudio();

    expect(saved.whiteNoise, ['rain']);
  });

  test('백색소음을 껐다 켜도 설정이 한 벌만 유지된다', () async {
    for (final selection in [
      ['rain'],
      ['rain', 'birds'],
      <String>[],
    ]) {
      final session = await _AppSession.start();
      final source = AudioDataSource(session.audios);
      final audio = await source.getOrCreateAudio();
      audio.whiteNoise = selection;
      await source.updateAudio(audio);
    }

    final restarted = await _AppSession.start();
    expect(restarted.audios.count, 1, reason: '설정이 중복 저장되면 안 된다');
    expect(
      (await AudioDataSource(restarted.audios).getOrCreateAudio()).whiteNoise,
      isEmpty,
    );
  });

  test('선택한 캐릭터는 재시작 후에도 남는다', () async {
    final first = await _AppSession.start();
    await CharacterDataSource(first.characters).insertDefaultCharacters();
    final selection = SelectedCharacterDataSource(first.selectedCharacters);
    await selection.setSelectedCharacter(defaultCharacters.last.name);

    final restarted = await _AppSession.start();
    final saved = await SelectedCharacterDataSource(restarted.selectedCharacters)
        .getSelectedCharacter();

    expect(saved?.name, defaultCharacters.last.name);
  });

  test('기본 캐릭터 시드는 재시작해도 다시 심지 않는다', () async {
    final first = await _AppSession.start();
    await CharacterDataSource(first.characters).insertDefaultCharacters();
    final seeded = first.characters.count;

    final restarted = await _AppSession.start();
    await CharacterDataSource(restarted.characters).insertDefaultCharacters();

    expect(restarted.characters.count, seeded, reason: '시드가 중복되면 안 된다');
  });

  test('표시 이름 없이 저장돼 있던 캐릭터도 시드 이름으로 갱신된다', () async {
    // 표시 이름이 생기기 전 버전에서 설치한 기기를 흉내낸다.
    final old = await _AppSession.start();
    await old.characters.put(
      2,
      Character(
        id: 2,
        name: 'dog_white',
        travelframes: [0, 1, 2, 3],
        travelSprite: 'characters/dog_white_travel.png',
        idleSprite: 'characters/dog_white_idle.png',
        idleFrames: [0],
        isPremium: false,
      ),
    );
    expect(old.characters.getById(2)!.label, 'dog_white');

    final restarted = await _AppSession.start();
    await CharacterDataSource(restarted.characters).insertDefaultCharacters();

    expect(restarted.characters.getById(2)!.label, '대박이');
    expect(restarted.characters.getById(1)!.label, '우주인');
    expect(restarted.characters.count, defaultCharacters.length,
        reason: '갱신이지 추가가 아니다');
  });

  test('캐릭터 이름이 바뀌어도 선택 기록은 그대로 이어진다', () async {
    // 선택은 표시 이름이 아니라 슬러그(name)로 저장되므로 영향받지 않아야 한다.
    final first = await _AppSession.start();
    await CharacterDataSource(first.characters).insertDefaultCharacters();
    await SelectedCharacterDataSource(first.selectedCharacters)
        .setSelectedCharacter('dog_white');

    final restarted = await _AppSession.start();
    await CharacterDataSource(restarted.characters).insertDefaultCharacters();
    final selected = await SelectedCharacterDataSource(
      restarted.selectedCharacters,
    ).getSelectedCharacter();
    final character =
        await CharacterDataSource(restarted.characters).getCharacter(
      selected!.name,
    );

    expect(character?.label, '대박이');
  });
}
