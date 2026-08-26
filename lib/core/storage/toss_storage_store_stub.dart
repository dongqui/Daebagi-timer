import 'key_value_store.dart';

/// 비웹 빌드용 stub. 앱인토스 웹뷰는 웹 빌드에서만 존재하므로 항상 사용 불가다.
class TossStorageStore implements KeyValueStore {
  /// 네이티브 빌드는 토스 웹뷰 안에서 돌 수 없다.
  static bool get isTossWebView => false;

  /// 이 빌드에서는 앱인토스 Storage를 쓸 수 없다.
  static bool get isAvailable => false;

  @override
  Future<void> init() async {
    throw UnsupportedError('TossStorageStore는 웹 빌드에서만 사용할 수 있습니다.');
  }

  @override
  Future<String?> read(String key) async {
    throw UnsupportedError('TossStorageStore는 웹 빌드에서만 사용할 수 있습니다.');
  }

  @override
  Future<void> write(String key, String value) async {
    throw UnsupportedError('TossStorageStore는 웹 빌드에서만 사용할 수 있습니다.');
  }

  @override
  Future<void> delete(String key) async {
    throw UnsupportedError('TossStorageStore는 웹 빌드에서만 사용할 수 있습니다.');
  }
}
