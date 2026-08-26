import 'package:catodo/core/navigation/app_back_dispatcher.dart';
import 'package:catodo/core/navigation/toss_back_bridge.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 앱 전역 뒤로가기 배선. [MainScreen]에서 한 번 호출한다.
class AppBackBinding {
  static void Function()? _unsubscribe;
  static bool _configured = false;

  /// [navigatorKey]로 다이얼로그 pop을 연결하고, 앱인토스 `backEvent`를 구독한다.
  static void ensureStarted(GlobalKey<NavigatorState> navigatorKey) {
    if (!_configured) {
      _configured = true;
      final dispatcher = AppBackDispatcher.instance;
      dispatcher.canPopNavigator =
          () => navigatorKey.currentState?.canPop() ?? false;
      dispatcher.popNavigator = () {
        navigatorKey.currentState?.pop();
      };
      dispatcher.onExit = _exitApp;
    }

    _unsubscribe ??= TossBackBridge.subscribeBackEvent(_onTossBack);
  }

  static void _onTossBack() {
    final dispatcher = AppBackDispatcher.instance;
    final busy = TimerManager.instance.state.status != TimerStatus.idle;
    final previousExit = dispatcher.onExit;
    // 집중 세션 중에는 루트 뒤로가기로 미니앱이 종료되지 않게 한다.
    if (busy) {
      dispatcher.onExit = null;
    }
    try {
      dispatcher.handleBack();
    } finally {
      dispatcher.onExit = previousExit;
    }
  }

  static void _exitApp() {
    if (TossBackBridge.isAvailable) {
      TossBackBridge.closeView();
      return;
    }
    SystemNavigator.pop();
  }

  /// 테스트용 리셋.
  static void resetForTest() {
    _unsubscribe?.call();
    _unsubscribe = null;
    _configured = false;
    AppBackDispatcher.instance
      ..onExit = null
      ..canPopNavigator = null
      ..popNavigator = null;
  }
}
