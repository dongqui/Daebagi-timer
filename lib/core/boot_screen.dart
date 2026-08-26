/// `web/index.html`의 부트 화면을 걷어내는 함수의 플랫폼 분기 지점.
///
/// 웹에서는 실제로 DOM을 정리하고, 네이티브 빌드에서는 아무것도 하지 않는다.
/// (네이티브는 OS 스플래시가 첫 프레임까지 자리를 지켜준다.)
library;

export 'boot_screen_stub.dart'
    if (dart.library.js_interop) 'boot_screen_web.dart';
