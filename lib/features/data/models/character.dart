final List<Character> defaultCharacters = [
  Character(
      id: 2,
      name: 'dog_white',
      travelframes: [0, 1, 2, 3],
      travelSprite: 'characters/dog_white_travel.png',
      idleSprite: 'characters/dog_white_idle.png',
      idleFrames: [0],
      isPremium: false),
  Character(
      id: 1,
      name: 'astronaut',
      travelframes: [0],
      travelSprite: 'characters/astronaut_travel.png',
      idleSprite: 'characters/astronaut_idle.png',
      idleFrames: [0],
      isPremium: false),
];

class Character {
  /// 앱이 직접 지정하는 id (기본 캐릭터 시드 + 서버 리소스 id). 자동 증가가 아니다.
  int id;

  late String name;
  late List<int> travelframes;
  late String travelSprite;
  late String idleSprite;
  late List<int> idleFrames;
  late bool isPremium;

  Character({
    required this.id,
    required this.name,
    required this.travelframes,
    required this.travelSprite,
    required this.idleSprite,
    required this.idleFrames,
    required this.isPremium,
  });

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'] as int,
        name: json['name'] as String,
        travelframes: List<int>.from(json['travelframes'] as List),
        travelSprite: json['travelSprite'] as String,
        idleSprite: json['idleSprite'] as String,
        idleFrames: List<int>.from(json['idleFrames'] as List),
        isPremium: json['isPremium'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'travelframes': travelframes,
        'travelSprite': travelSprite,
        'idleSprite': idleSprite,
        'idleFrames': idleFrames,
        'isPremium': isPremium,
      };
}
