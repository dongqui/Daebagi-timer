/// 번들 이미지 경로를 Flutter [Image.asset] 형식으로 통일한다.
///
/// - `assets/images/...` 전체 경로
/// - `characters/foo.png` 같은 Flame/DB 상대 경로
/// 둘 다 받아서 `assets/images/...`로 정규화한다.
String assetImagePath(String path) {
  if (path.startsWith('assets/')) return path;
  return 'assets/images/$path';
}
