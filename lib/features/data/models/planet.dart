final defaultPlanets = [
  Planet(
      id: 1, name: '', url: 'planets/premium/p_planet_1.gif', isPremium: true),
  Planet(
      id: 2, name: '', url: 'planets/premium/p_planet_2.gif', isPremium: true),
  Planet(
      id: 3, name: '', url: 'planets/premium/p_planet_3.gif', isPremium: true),
];

class Planet {
  /// 앱이 직접 지정하는 id (기본 행성 시드 + 서버 리소스 id). 자동 증가가 아니다.
  int id;

  late String name;
  late String url;
  late bool isPremium;

  Planet({
    required this.id,
    required this.name,
    required this.url,
    required this.isPremium,
  });

  factory Planet.fromJson(Map<String, dynamic> json) => Planet(
        id: json['id'] as int,
        name: json['name'] as String,
        url: json['url'] as String,
        isPremium: json['isPremium'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'isPremium': isPremium,
      };
}
