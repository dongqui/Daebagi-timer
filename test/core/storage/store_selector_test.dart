import 'package:flutter/foundation.dart';

import 'package:catodo/core/storage/key_value_store.dart';
import 'package:catodo/core/storage/store_selector.dart';
import 'package:catodo/core/storage/toss_storage_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/in_memory_key_value_store.dart';

/// init()이 항상 실패하는 store — 초기화 실패 fallback 검증용.
class _FailingStore implements KeyValueStore {
  @override
  Future<void> init() async {
    throw StateError('의도된 초기화 실패');
  }

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {}

  @override
  Future<void> delete(String key) async {}
}

void main() {
  group('createDefaultKeyValueStore', () {
    test('앱인토스 환경이면 토스 store를 고르고 init한다', () async {
      final tossStore = InMemoryKeyValueStore();

      final selected = await createDefaultKeyValueStore(
        isTossAvailable: () => true,
        createTossStore: () => tossStore,
        createFallbackStore: () => fail('앱인토스 환경에서는 fallback을 만들면 안 된다'),
      );

      expect(selected, same(tossStore));
      expect(tossStore.initCount, 1);
    });

    test('앱인토스 환경이 아니면 fallback store를 고른다', () async {
      final fallbackStore = InMemoryKeyValueStore();

      final selected = await createDefaultKeyValueStore(
        isTossAvailable: () => false,
        createTossStore: () => fail('미감지 시 토스 store를 만들면 안 된다'),
        createFallbackStore: () => fallbackStore,
      );

      expect(selected, same(fallbackStore));
      expect(fallbackStore.initCount, 1);
    });

    test('토스 store 초기화가 실패하면 fallback으로 넘어간다', () async {
      final fallbackStore = InMemoryKeyValueStore();

      final selected = await createDefaultKeyValueStore(
        isTossAvailable: () => true,
        createTossStore: () => _FailingStore(),
        createFallbackStore: () => fallbackStore,
      );

      expect(selected, same(fallbackStore));
      expect(fallbackStore.initCount, 1);
    });

    test('앱인토스 웹뷰인데 Storage API가 없으면 경고를 남긴다', () async {
      // 데이터가 조용히 사라지는 유일한 경로다. 토스 웹뷰 안인데 SDK 번들을
      // 못 찾으면 localStorage로 내려가고, iOS는 7일 뒤 그걸 지운다.
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
      addTearDown(() => debugPrint = original);

      final fallbackStore = InMemoryKeyValueStore();
      final selected = await createDefaultKeyValueStore(
        isTossAvailable: () => false,
        isTossWebView: () => true,
        createTossStore: () => fail('Storage API가 없으면 토스 store를 만들면 안 된다'),
        createFallbackStore: () => fallbackStore,
      );

      expect(selected, same(fallbackStore));
      expect(
        logs.join('\n'),
        contains('Storage API를 찾지 못했습니다'),
        reason: '조용히 fallback하면 안 된다',
      );
    });

    test('일반 브라우저에서의 fallback은 경고 없이 지나간다', () async {
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
      addTearDown(() => debugPrint = original);

      await createDefaultKeyValueStore(
        isTossAvailable: () => false,
        isTossWebView: () => false,
        createFallbackStore: InMemoryKeyValueStore.new,
      );

      expect(logs.join('\n'), isNot(contains('경고')));
    });

    test('VM(비웹) 빌드에서는 TossStorageStore가 사용 불가로 감지된다', () {
      expect(TossStorageStore.isAvailable, isFalse);
      expect(TossStorageStore.isTossWebView, isFalse);
    });
  });
}
