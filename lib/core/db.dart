import 'package:catodo/core/storage/document_store.dart';
import 'package:catodo/core/storage/key_value_store.dart';
import 'package:catodo/core/storage/store_selector.dart';
import 'package:catodo/features/data/models/focus_session_model.dart';
import 'package:catodo/features/data/models/latest-activity-model.dart';
import 'package:catodo/features/data/datasources/focus_session_datasource.dart';
import 'package:catodo/features/data/datasources/latest-activity-datasource.dart';
import 'package:catodo/features/data/repositories/focus_session_repository.dart';
import 'package:catodo/features/data/repositories/latest_activity_repository.dart';
import 'package:catodo/features/data/datasources/audio_datasource.dart';
import 'package:catodo/features/data/repositories/audio_repository.dart';
import 'package:catodo/features/data/models/audio_model.dart';
import 'package:catodo/features/data/datasources/chacater-datasource.dart';
import 'package:catodo/features/data/repositories/character_repository.dart';
import 'package:catodo/features/data/datasources/selected_character_datasource.dart';
import 'package:catodo/features/data/repositories/selected_character_repository.dart';
import 'package:catodo/features/data/models/character.dart';
import 'package:catodo/features/data/models/selected_character.dart';
import 'package:catodo/features/data/datasources/discovery_datasource.dart';
import 'package:catodo/features/data/repositories/discovery_repository.dart';
import 'package:catodo/features/data/models/discovery.dart';
import 'package:catodo/features/data/models/planet.dart';
import 'package:catodo/features/data/datasources/planet_datasource.dart';
import 'package:catodo/features/data/repositories/planet_repository.dart';

/// 저장소 조립 지점.
///
/// 컬렉션을 추가할 때는 여기에 [DocumentStore]를 하나 만들고 datasource/repository
/// 초기화 쌍을 추가한다. 모든 store는 datasource를 만들기 전에 [DocumentStore.load]가
/// 끝나 있어야 한다 — 이후 query()가 동기 호출이 되는 전제다.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;
  DatabaseService._internal();

  KeyValueStore? _backend;

  KeyValueStore get backend {
    final backend = _backend;
    if (backend == null) {
      throw StateError('DatabaseService.setUpDB()가 아직 호출되지 않았습니다.');
    }
    return backend;
  }

  Future<void> setUpDB() async {
    final backend = await createDefaultKeyValueStore();
    _backend = backend;

    // store
    final focusSessionStore = DocumentStore<FocusSession>(
      backend: backend,
      collection: 'focusSessions',
      toJson: (item) => item.toJson(),
      fromJson: FocusSession.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    final latestActivityStore = DocumentStore<LatestActivity>(
      backend: backend,
      collection: 'latestActivities',
      toJson: (item) => item.toJson(),
      fromJson: LatestActivity.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    final audioStore = DocumentStore<Audio>(
      backend: backend,
      collection: 'audios',
      toJson: (item) => item.toJson(),
      fromJson: Audio.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    final characterStore = DocumentStore<Character>(
      backend: backend,
      collection: 'characters',
      toJson: (item) => item.toJson(),
      fromJson: Character.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    final selectedCharacterStore = DocumentStore<SelectedCharacter>(
      backend: backend,
      collection: 'selectedCharacters',
      toJson: (item) => item.toJson(),
      fromJson: SelectedCharacter.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    final discoveryStore = DocumentStore<Discovery>(
      backend: backend,
      collection: 'discoveries',
      toJson: (item) => item.toJson(),
      fromJson: Discovery.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    final planetStore = DocumentStore<Planet>(
      backend: backend,
      collection: 'planets',
      toJson: (item) => item.toJson(),
      fromJson: Planet.fromJson,
      getId: (item) => item.id,
      setId: (item, id) => item.id = id,
    );
    // datasource를 만들기 전에 메모리 캐시를 채운다.
    await Future.wait([
      focusSessionStore.load(),
      latestActivityStore.load(),
      audioStore.load(),
      characterStore.load(),
      selectedCharacterStore.load(),
      discoveryStore.load(),
      planetStore.load(),
    ]);

    // datasource
    final focusSessionDataSource = FocusSessionDataSource(focusSessionStore);
    final latestActivityDataSource =
        LatestActivityDataSource(latestActivityStore);
    final audioDataSource = AudioDataSource(audioStore);
    final characterDataSource = CharacterDataSource(characterStore);
    final selectedCharacterDataSource =
        SelectedCharacterDataSource(selectedCharacterStore);
    final discoveryDataSource =
        DiscoveryDataSource(discoveryStore, planetStore);
    final planetDataSource = PlanetDataSource(planetStore);

    // repository
    FocusSessionRepository.initialize(focusSessionDataSource);
    LatestActivityRepository.initialize(latestActivityDataSource);
    AudioRepository.initialize(audioDataSource);
    CharacterRepository.initialize(characterDataSource);
    SelectedCharacterRepository.initialize(selectedCharacterDataSource);
    DiscoveryRepository.initialize(discoveryDataSource);
    PlanetRepository.initialize(planetDataSource);
  }
}
