import 'package:flutter/foundation.dart';

import 'key_value_store.dart';
import 'shared_preferences_store.dart';
import 'toss_storage_store.dart';

/// 실행 환경에 맞는 [KeyValueStore]를 고른다.
///
/// 앱인토스 웹뷰에서는 네이티브 저장소로 브릿지되는 [TossStorageStore]를 쓴다
/// (IndexedDB 7일 삭제 정책 회피). 감지 실패나 초기화 실패 시에는
/// [SharedPreferencesStore]로 fallback한다.
///
/// 파라미터는 전부 테스트 주입용이다 — 프로덕션에서는 인자 없이 호출한다.
Future<KeyValueStore> createDefaultKeyValueStore({
  bool Function()? isTossAvailable,
  bool Function()? isTossWebView,
  KeyValueStore Function()? createTossStore,
  KeyValueStore Function()? createFallbackStore,
}) async {
  final tossAvailable = isTossAvailable ?? () => TossStorageStore.isAvailable;
  final inTossWebView = isTossWebView ?? () => TossStorageStore.isTossWebView;

  if (tossAvailable()) {
    try {
      final store = (createTossStore ?? TossStorageStore.new)();
      await store.init();
      debugPrint('저장소: 앱인토스 Storage (네이티브 브릿지)');
      return store;
    } catch (e) {
      debugPrint('TossStorageStore 초기화 실패, SharedPreferences로 fallback: $e');
    }
  } else if (inTossWebView()) {
    // 이 조합이 가장 위험하다. 토스 웹뷰 안인데 SDK 번들을 못 찾았다는 뜻이고,
    // 그대로 fallback하면 웹에서는 localStorage로 내려간다 — iOS가 7일 미접속 시
    // 지워버리는 바로 그 저장소다. 조용히 넘어가면 사용자 기록이 사라진 뒤에야
    // 알게 되므로 반드시 눈에 띄게 남긴다.
    debugPrint(
      '경고: 앱인토스 웹뷰인데 Storage API를 찾지 못했습니다. '
      'web/index.html의 SDK 번들 로드를 확인하세요. '
      'localStorage로 fallback하면 iOS에서 7일 뒤 데이터가 삭제될 수 있습니다.',
    );
  }

  final store = (createFallbackStore ?? SharedPreferencesStore.new)();
  await store.init();
  debugPrint('저장소: SharedPreferences');
  return store;
}
