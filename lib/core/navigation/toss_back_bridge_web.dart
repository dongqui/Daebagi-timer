import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// `web/js/apps_in_toss.js`가 노출하는 전역 (`AppsInTossModule`).
@JS('AppsInTossModule')
external _AppsInTossModule? get _appsInTossModule;

@JS('ReactNativeWebView')
external JSObject? get _reactNativeWebView;

extension type _AppsInTossModule(JSObject _) implements JSObject {
  @JS('graniteEvent')
  external _GraniteEvent? get graniteEvent;

  @JS('closeView')
  external JSPromise<JSAny?> closeView();
}

extension type _GraniteEvent(JSObject _) implements JSObject {
  external JSFunction addEventListener(JSString event, JSObject args);
}

/// 앱인토스 `graniteEvent.backEvent` / `closeView` 브릿지.
class TossBackBridge {
  /// 토스 웹뷰이고 SDK에 graniteEvent가 있는가.
  static bool get isAvailable =>
      _reactNativeWebView != null && _appsInTossModule?.graniteEvent != null;

  /// 뒤로가기 구독. 구독 해제 함수를 반환한다. 불가 환경이면 null.
  ///
  /// 구독 시 네이티브 기본 뒤로가기(미니앱 종료)는 차단된다.
  static void Function()? subscribeBackEvent(void Function() onBack) {
    final granite = _appsInTossModule?.graniteEvent;
    if (_reactNativeWebView == null || granite == null) return null;

    final args = JSObject()
      ..['onEvent'] = onBack.toJS
      ..['onError'] = ((JSAny error) {
        // ignore: avoid_print
        print('TossBackBridge backEvent error: $error');
      }).toJS;

    final unsubscribe = granite.addEventListener('backEvent'.toJS, args);

    return () {
      unsubscribe.callAsFunction();
    };
  }

  static Future<void> closeView() async {
    final module = _appsInTossModule;
    if (module == null) return;
    await module.closeView().toDart;
  }
}
