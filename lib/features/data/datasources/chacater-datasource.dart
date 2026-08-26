import 'package:catodo/core/storage/document_store.dart';
import 'package:catodo/features/data/models/character.dart';

class CharacterDataSource {
  final DocumentStore<Character> _store;

  CharacterDataSource(this._store);

  /// 번들에 들어있는 기본 캐릭터를 DB에 맞춰 넣는다.
  ///
  /// id로 덮어쓰기 때문에 매번 불러도 중복되지 않고, 이미 설치된 기기에서도
  /// 표시 이름이나 스프라이트 경로 같은 메타데이터가 최신 시드로 갱신된다.
  /// (선택한 캐릭터는 별도 컬렉션이라 영향받지 않는다.)
  Future<void> insertDefaultCharacters() async {
    for (final character in defaultCharacters) {
      // 시드 상수를 저장소와 공유하지 않도록 복사해서 넣는다.
      await _store.put(character.id, Character.fromJson(character.toJson()));
    }
  }

  // 캐릭터 리스트 반환
  Future<List<Character>> getCharacters() async {
    return _store.query();
  }

  // 이름으로 캐릭터 정보 반환
  Future<Character?> getCharacter(String characterName) async {
    final matches = _store.query(where: (c) => c.name == characterName);
    return matches.isEmpty ? null : matches.first;
  }

  // 캐릭터 업데이트 또는 추가
  Future<void> updateCharacter(Character character) async {
    await _store.put(character.id, character);
  }
}
