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
    // 투명(true)으로 두면 콘텐츠가 네비게이션 바 아래로 파고들어, 우리 메뉴 버튼이
    // 토스의 더보기(...)·닫기(X)와 겹친다. 불투명으로 두면 토스가 그만큼 자리를
    // 비워주므로 화면 전체가 그 아래에서 시작한다.
    // 전체화면 느낌을 되찾고 싶으면 true로 바꾸되, 상단 요소들을 네비게이션 바
    // 높이만큼 따로 내려야 한다.
    transparentBackground: false,
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
