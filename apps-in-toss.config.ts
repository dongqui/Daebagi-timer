import { defineConfig } from "@apps-in-toss/web-framework/config";

// 앱인토스 미니앱 배포 설정 (`ait build` / `ait deploy`가 읽는다).
// appName은 앱인토스 콘솔에 등록한 이름과 일치해야 한다.
// webBundleDir은 `npm run build:web`(= flutter build web --release) 산출물 경로다.
//
// 주의: 미니앱이 서비스되는 Origin은 @apps-in-toss/web-framework 버전에 묶여
// 있다. 3.0.x는 `{appName}.web.tossmini.com`, 3.1.1부터는
// `{appName}.apps.tossmini.com`이다. 버전을 올리면 Origin이 바뀌고, 그러면
// localStorage·IndexedDB에 쌓인 기존 데이터가 새 Origin에서 보이지 않는다.
// 출시 후 올릴 때는 SDK의 `Migration.getOriginStorage()`로 옛 Origin 데이터를
// 읽어 병합해야 한다. (우리 주 저장 경로는 네이티브 브릿지라 영향이 덜하지만,
// SDK 번들을 못 찾았을 때의 fallback은 localStorage다.)
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
    // 투명하게 두면 배경이 화면 끝까지 이어진다. 토스가 실제로 쓰는 건 그 줄의
    // 오른쪽 끝(더보기·닫기)뿐이라, 같은 줄 왼쪽은 우리 버튼 자리로 쓴다.
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
