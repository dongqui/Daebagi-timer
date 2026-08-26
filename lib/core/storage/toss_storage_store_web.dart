import 'dart:js_interop';

import 'key_value_store.dart';

/// `web/index.html`이 로드하는 SDK 번들이 노출하는 전역
/// (`esbuild --global-name=AppsInTossModule`, `toss/apps_in_toss_entry.js` 참조).
@JS('AppsInTossModule')
external _AppsInTossModule? get _appsInTossModule;

/// 토스 앱 웹뷰가 주입하는 브릿지. SDK 자체가 이 값의 존재로 웹뷰 여부를
/// 판별하며, 일반 브라우저에는 없다.
@JS('ReactNativeWebView')
external JSObject? get _reactNativeWebView;

extension type _AppsInTossModule(JSObject _) implements JSObject {
  @JS('Storage')
  external _TossStorage? get storage;
}

/// 앱인토스 `Storage` API. 네이티브 저장소로 브릿지되며 문자열 전용이다.
extension type _TossStorage(JSObject _) implements JSObject {
  external JSPromise<JSString?> getItem(JSString key);
  external JSPromise<JSAny?> setItem(JSString key, JSString value);
  external JSPromise<JSAny?> removeItem(JSString key);
}

/// 앱인토스 Storage API 기반 [KeyValueStore].
///
/// 네이티브 저장소로 브릿지되므로 IndexedDB의 iOS 7일 미접속 삭제 정책을
/// 받지 않는다. 토스 웹뷰 안에서만 동작하며([isAvailable]), 그 밖에서는
/// [SharedPreferencesStore]로 fallback해야 한다.
class TossStorageStore implements KeyValueStore {
  _TossStorage? _storage;

  /// 토스 앱 웹뷰 안에서 돌고 있는가. SDK 번들 로드 여부와는 별개다.
  static bool get isTossWebView => _reactNativeWebView != null;

  /// 토스 웹뷰 안이고 SDK 번들이 로드되어 있는가.
  static bool get isAvailable =>
      isTossWebView && _appsInTossModule?.storage != null;

  @override
  Future<void> init() async {
    final storage = _appsInTossModule?.storage;
    if (_reactNativeWebView == null || storage == null) {
      throw StateError(
          '앱인토스 웹뷰 환경이 아닙니다. isAvailable을 먼저 확인하세요.');
    }
    _storage = storage;
  }

  @override
  Future<String?> read(String key) async {
    final value = await _requireStorage().getItem(key.toJS).toDart;
    return value?.toDart;
  }

  @override
  Future<void> write(String key, String value) async {
    await _requireStorage().setItem(key.toJS, value.toJS).toDart;
  }

  @override
  Future<void> delete(String key) async {
    await _requireStorage().removeItem(key.toJS).toDart;
  }

  _TossStorage _requireStorage() {
    final storage = _storage;
    if (storage == null) {
      throw StateError('TossStorageStore를 init() 전에 사용했습니다.');
    }
    return storage;
  }
}
