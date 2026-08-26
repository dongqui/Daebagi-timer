# TDS 기반 UI 리팩토링 설계

- 작성일: 2026-08-26
- 디자인 원본: Claude Design 프로젝트 `타이머 앱 UI 디자인` / `TimerApp.dc.html`
  (projectId `6ec679d9-92a0-4452-886e-a0486c57dd8b`)
- 디자인 시스템: `TDS Mobile Design System` (projectId `37dd7360-cdd7-49b8-95b8-c3d814e05134`)

## 목표

색·간격·타이포가 오버레이마다 하드코딩된 현 상태를 걷어내고, TDS 다크 토큰과
재사용 위젯 위에 화면 6개를 다시 세운다.

## A. 디자인 토큰 — `lib/theme/`

Figma Variables(`tokens/fig-tokens.css`)의 `:root[data-theme="dark"]` 값을 해석해 Dart 상수로 고정.

| 토큰 | 값 |
| --- | --- |
| `bgDefault` | `#17171C` |
| `bgLower` | `#101013` |
| `bgFloated` | `#202027` |
| `bgDim` | `rgba(0,0,0,.56)` |
| `textStrong` | `#FFFFFF` |
| `textPrimary` | `#E4E4E5` |
| `textSecondary` | `rgba(253,253,255,.75)` |
| `textTertiary` | `rgba(248,248,255,.60)` |
| `textQuaternary` | `rgba(242,242,255,.47)` |
| `brand` | `#3182F6` |
| `brandText` | `#449BFF` |
| `danger` | `#F04251` |
| `success` | `#16BB76` |
| `warning` | `#FFB134` |
| `border` | `rgba(222,222,255,.19)` |
| `fillNeutralWeak` | `rgba(217,217,255,.11)` |

파일 구성:

- `tds_colors.dart` — 위 팔레트
- `tds_typography.dart` — 디자인에 실제 쓰인 스케일만. CSS 웨이트 510 → `w500`, 590 → `w600`
- `tds_metrics.dart` — radius / pageMargin / controlHeight / gap / blur / easing / duration
- `app_theme.dart` — 다크 `ThemeData` 조립

## B. 위젯 라이브러리 — `lib/widgets/tds/`

디자인이 실제로 참조하는 TDS 컴포넌트만 포팅한다. 전부 순수 표현 위젯이며
매니저 싱글턴을 직접 참조하지 않는다.

`TdsButton` · `TdsTextButton` · `TdsIconButton` · `TdsTextField` · `TdsNumericSpinner` ·
`TdsSegmentedControl` · `TdsNavigation` · `TdsListRow` · `TdsListHeader` · `TdsBottomCta` ·
`TdsCheckbox` · `TdsBorder` · `TdsLoader` · `TdsArrow`

앱 전용 위젯 2개:

- `TdsGlassPanel` — 디자인에 4회 반복되는 유리 패널
  (`rgba(28,30,36,.82)` + `blur(22)` + inset ring `rgba(253,253,255,.10)`)
- `SpaceBackdrop` — `parallax/stars_bot|mid|top.png` 3겹 + 라디얼 그라디언트 + 선택적 `planet.png`

## C. 화면

| 화면 | 파일 | 요지 |
| --- | --- | --- |
| 인트로 | `views/splash_screen.dart` | `SpaceBackdrop` 배경, 캐릭터 210px, "대박이 타이머"(24/700) + 부제(15, .5), 하단 `TdsLoader`, rise → handoff 전환 |
| 홈 | `views/overlays/home_overlay.dart` | 셔틀 웨이브 버튼 **현행 유지**. 우상단 메뉴만 `TdsGlassPanel` + `TdsIconButton` (top 52 / right 16) |
| 설정 | `views/overlays/focus_form_overlay.dart`, `views/focus_form/form.dart` | `SpaceBackdrop` + `TdsNavigation` + 상단 radius 28 시트(핸들 → `TdsTextField` → `TdsListHeader` → 시/분/초 `TdsNumericSpinner` → 브랜드 합계 라벨 → `TdsBottomCta` + XL) |
| 타이머 | `views/overlays/timer_overlay/timer_overlay.dart` | 상단 작업명(15/.6) + 시간(44/700 tabular). 좌하단 백색소음 유리 패널, 우하단 유리 pill 3버튼 |
| 기록 | `views/stats/stats_screen.dart` (신규) | 독립 화면 승격. Navigation → 캐릭터 150px → Border → 일/주/월/년 → 기간 이동 → 차트/빈 상태 → Border → 총 집중 시간·세션 |
| 완료 | `views/overlays/focus_end_overlay.dart` | 상단 300px `SpaceBackdrop` → 제목(24/700) + "기록에 저장했어요" → ListRow 3개 → `TdsBottomCta`(XL + TextButton) |

`views/overlays/settings/` 의 캐릭터·발견 설정은 기록 화면 우상단 "꾸미기" 버튼 뒤로 이동한다
(디자인의 `editNavButton` 역할).

## D. 결정 사항

- **홈 CTA**: 디자인의 3개 변형 중 어느 것도 채택하지 않고 현재 셔틀 웨이브 버튼을 유지한다.
- **인트로 이미지**: 디자인 원본의 `assets/dog-cutout.png`는 MCP 전송 상한(256KiB)에 걸려
  640×857 중 323행만 수신되어 받아올 수 없었다. 대신 직접 넣어준
  `assets/images/dog_photo_cutout-v2.png`(1083×1452, RGBA)를 쓴다. 투명 여백을 잘라내고
  가로 640px로 줄여 `assets/images/dog_cutout.webp`(640×1113, 92KB)로 저장했다.
  같은 그림을 PNG로 두면 700KB가 넘어서 WebP를 골랐다 — 표시 크기(210pt)에서 차이가
  보이지 않는다. 원본 PNG들은 `pubspec.yaml`에 등록하지 않아 번들에 들어가지 않는다.

  첫 버전 `dog_photo_cutout.png`는 알파 채널이 없고(PNG colortype 2) 편집기의
  체크무늬가 픽셀에 구워져 있어 쓸 수 없었다. 색으로 배경을 골라내 알파를 복원해봤지만
  머리 위 잔털이 침식에 깎여서 폐기하고 파일도 지웠다 — 알파가 살아있는 원본을 받는
  쪽이 언제나 낫다.
- **배경**: `focus_form` / `focusEnd` 오버레이는 `SpaceBackdrop` 위젯을 배경으로 깐다.
  (뒤에 Flame 월드가 실제로 렌더되고 있지만 상태에 따라 홈/타이머 월드가 달라져
  화면마다 배경이 달라지므로, 결정적인 정적 배경을 택한다.)

- **무제한(∞) 집중 시간**: 예전 시간 선택기의 첫 항목 `-1`(무제한)은 디자인의
  시/분/초 스피너에 대응하는 자리가 없어 빠졌다. 최대 12시간 0분 0초까지 고를 수 있다.
  다시 넣으려면 스피너 아래 토글을 추가하는 등 디자인 변경이 필요하다.
- **최근 활동 칩**: 디자인에는 없지만 기존 기능이라 유지했다. TDS 토큰으로 다시 그렸고,
  이제서야 실제로 채워진다 — 예전 `form.dart`는 `addLatestActivity()`를 아예 부르지 않아
  목록이 늘 비어 있었다.

## D-2. 사용해보고 조정한 것

- **전환 연출 제거** — `FullScreenOverlay`의 페이드·스케일을 뺐다. 닫을 때 뒤 화면이
  잠깐 비쳐 멈칫하는 것처럼 보였다. 이제 즉시 나타나고 즉시 사라진다.
- **완료 → 기록 직행** — '기록 보기'는 `goToStats()`로 idle을 거치므로 홈 오버레이가
  한 프레임 보였다. `HomeOverlay.initState`에서 대기 중인 요청을 바로 읽어
  첫 빌드부터 기록 화면이 올라와 있게 했다(예전에는 `postFrameCallback`).
- **기록 화면** — 제목 '집중 기록'을 빼고, 캐릭터 영역 배경은 별 대신 검정으로,
  꾸미기 버튼은 L 크기 + 흰색 아이콘으로 키웠다. 캐릭터 선택 화면 배경도 검정.
- **집중 준비 화면** — '어떤 일에…' 라벨을 `TdsText.subtitle`로 올려
  '얼마나 집중하실…'(`TdsListHeader`)과 급을 맞췄다. `TdsTextField`에 `labelStyle` 추가.
- **스피너 직접 입력** — 가운데 숫자를 누르면 입력 필드로 바뀐다. 확정할 때
  min/max로 clamp하고, 빈 값이면 원래 값을 유지한다.
- **타이머 위치** — 상단 고정에서 `Alignment(0, -0.5)`로 내렸다. 캐릭터가 화면
  세로 중앙에 뜨므로 화면 위쪽 끝과 캐릭터의 중간쯤이 된다.
- **백색소음 패널** — 왼쪽 아래에서 컨트롤 바의 음표 아이콘 위(오른쪽 기준)로 옮기고,
  아이콘에서 튀어나오듯 우하단 기준 스케일·페이드를 붙였다.
- **인트로 배경** — 검정에서 `SpaceBackdrop`으로 바꿨다. 검정 위에서는 캐릭터가 허공에
  뜬 것처럼 보였고, 별을 깔면 게임 월드와 같은 에셋이라 인트로부터 우주로 이어진다.
  흰 아웃라인이 들어간 캐릭터도 만들어봤지만 쓰지 않았다 — 배경이 어두워 흰 털이 이미
  충분히 떠오르는데, 아웃라인이 알파 경계를 따라가며 가장자리 거칠기만 도드라졌다.
- **별 레이어 디코딩 크기** — 원본이 2752x2064라 그대로 읽으면 장당 20MB가 넘는 비트맵이
  세 개 뜬다. `cacheWidth`로 화면 폭에 맞춰 줄여 읽는다.

## E. 부수 수정

1. **저장 시각** — `FormManager._state.date`가 매니저 생성 시점의 `DateTime.now()`로
   고정되어 있어, 앱을 켜둔 채 여러 세션을 진행하면 모두 같은 시각으로 저장됐다.
   차트가 세션을 시간대·요일별로 나눌 때 이 값을 쓰므로 기록 자체가 틀어지는 문제였다.
   `save()` 시점의 `DateTime.now()`를 쓴다.
2. **백색소음이 패널과 함께 꺼지던 문제** — `AudioController`를 `AudioBox`가 소유해서
   패널을 닫으면 `dispose()`가 불려 소리까지 멎었다. 컨트롤러를 타이머 화면으로 올린다.
   저장된 선택은 타이머 진입 시 실제 재생으로 이어준다(예전에는 체크만 되고 소리는 안 났다).
3. **기간 라벨 오버플로** — 주 단위 라벨(`2026.08.24 ~ 2026.08.30`)이 좌우 이동 버튼과
   한 줄에 들어가지 않는다. 자르지 않고 `FittedBox`로 줄인다.
4. **`PageController` 누수** — `CharacterSelectors`가 컨트롤러를 dispose하지 않았다.
5. **스피너 입력 필드 폭** — 스피너는 `Row(mainAxisSize.min)` 안이라 폭이 무한대로
   열려 있어서, 숫자 칸에 `TextField`를 그냥 넣으면 레이아웃 단계에서 터진다.
   숫자 칸 크기(45px)로 못박았다. 위젯 테스트가 잡았다.

## E-2. 저장소 점검

`test/core/storage/persistence_across_restart_test.dart`에서 실제 기본 백엔드
(`shared_preferences`)로 앱을 껐다 켜는 상황을 흉내내 확인했다. 집중 기록, 최근 활동,
백색소음 선택, 선택한 캐릭터 모두 남는다.

점검하며 고친 것:

- **조용한 fallback** — 토스 웹뷰 안인데 SDK 번들을 못 찾으면 `isAvailable`이 false가 되어
  아무 로그 없이 `SharedPreferences`(웹에서는 localStorage)로 내려갔다. iOS가 7일 미접속 시
  지우는 바로 그 저장소라, 이 설계가 막으려던 문제가 그대로 재현되면서도 눈에 띄지 않는다.
  `isTossWebView`를 따로 노출해 이 조합에서 경고를 남기고, 어느 백엔드를 골랐는지 항상 찍는다.
- **백색소음 저장 실패 무시** — `unawaited(updateAudio(...))`가 예외를 삼켰다. `catchError`로 남긴다.
- **캐릭터 표시 이름** — `name`은 선택 기록의 키라 그대로 두고 `displayName`을 추가했다
  (`label` 게터가 없으면 `name`으로 되돌아간다). 이미 설치된 기기도 갱신되도록
  `insertDefaultCharacters()`를 "비어 있을 때만 삽입"에서 id 기준 upsert로 바꿨다.

아직 남은 것:

- **진행 중인 세션은 저장되지 않는다.** `TimerManager` 상태는 메모리에만 있어서, 집중 도중
  앱이 죽거나 웹뷰가 정리되면 그때까지의 시간이 통째로 사라진다. 별도 작업이 필요하다.
- 용량은 여유가 있다. 세션 1건이 JSON 119바이트라 localStorage 5MB 한도까지 약 44,000건
  (하루 10건이면 12년) 들어간다.

## F. 진행 순서

토큰 → TDS 위젯 → `SpaceBackdrop` → 화면(완료 → 설정 → 타이머 → 기록 → 인트로 → 홈).
각 단계마다 `flutter analyze` 통과를 확인한다.

## G. 검증

`test/widgets/tds_widgets_test.dart`, `test/features/presentation/*_test.dart`에서
375×812 프레임으로 각 화면을 띄워 오버플로가 없는지 확인한다. TDS 위젯은 상호작용
(스피너 min/max, 세그먼트 선택, 체크박스 토글, 비활성 버튼)까지 함께 검증한다.
