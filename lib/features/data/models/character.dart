final List<Character> defaultCharacters = [
  Character(
      id: 2,
      name: 'dog_white',
      displayName: '대박이',
      travelframes: [0, 1, 2, 3],
      travelSprite: 'characters/dog_white_travel.png',
      idleSprite: 'characters/dog_white_idle.png',
      idleFrames: [0],
      isPremium: false),
  Character(
      id: 1,
      name: 'astronaut',
      displayName: '우주인',
      travelframes: [0],
      travelSprite: 'characters/astronaut_travel.png',
      idleSprite: 'characters/astronaut_idle.png',
      idleFrames: [0],
      isPremium: false),
];

class Character {
  /// 앱이 직접 지정하는 id (기본 캐릭터 시드 + 서버 리소스 id). 자동 증가가 아니다.
  int id;

  /// 저장·조회에 쓰는 식별자(슬러그). 선택한 캐릭터도 이 값으로 기록되므로
  /// 한 번 정해지면 바꾸지 않는다. 화면에는 [label]을 쓸 것.
  late String name;

  /// 화면에 보여줄 이름. 없으면 [name]을 그대로 쓴다.
  String? displayName;

  late List<int> travelframes;
  late String travelSprite;
  late String idleSprite;
  late List<int> idleFrames;
  late bool isPremium;

  Character({
    required this.id,
    required this.name,
    this.displayName,
    required this.travelframes,
    required this.travelSprite,
    required this.idleSprite,
    required this.idleFrames,
    required this.isPremium,
  });

  /// 사용자에게 보여줄 이름.
  String get label => displayName ?? name;

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'] as int,
        name: json['name'] as String,
        // 표시 이름이 없던 시절에 저장된 기록도 그대로 읽힌다.
        displayName: json['displayName'] as String?,
        travelframes: List<int>.from(json['travelframes'] as List),
        travelSprite: json['travelSprite'] as String,
        idleSprite: json['idleSprite'] as String,
        idleFrames: List<int>.from(json['idleFrames'] as List),
        isPremium: json['isPremium'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'displayName': displayName,
        'travelframes': travelframes,
        'travelSprite': travelSprite,
        'idleSprite': idleSprite,
        'idleFrames': idleFrames,
        'isPremium': isPremium,
      };
}
