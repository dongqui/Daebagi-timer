import { defineConfig } from "@apps-in-toss/web-framework/config";

// 앱인토스 미니앱 배포 설정 (`ait build` / `ait deploy`가 읽는다).
// appName은 앱인토스 콘솔에 등록한 이름과 일치해야 한다.
// webBundleDir은 `npm run build:web`(= flutter build web --release) 산출물 경로다.
export default defineConfig({
  appName: "focuscope",
  brand: {
    primaryColor: "#3182F6",
  },
  navigationBar: {
    withBackButton: false,
    withHomeButton: false,
    withTitle: false,
    // 불투명(false)으로 두면 토스가 네비게이션 바 자리를 비워주지만, 그 바의
    // 배경색과 우리 별밭 배경이 만나는 지점에 또렷한 경계선이 생긴다.
    // 투명하게 두면 배경이 화면 끝까지 이어진다. 대신 콘텐츠가 네비게이션 바
    // 아래로 파고들므로, 그만큼의 여백은 `lib/core/toss_safe_area_web.dart`의
    // kTossNavigationBarHeight로 우리가 직접 비운다.
    transparentBackground: true,
    theme: "dark",
  },
  permissions: [],
  webView: {
    // 집중 타이머 도중 당겨서 새로고침되면 세션 화면이 리셋되므로 끈다.
    pullToRefreshEnabled: false,
    bounces: false,
  },
  webBundleDir: "build/web",
});
