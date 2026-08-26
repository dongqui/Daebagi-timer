/// 앱/오버레이 뒤로가기 처리 스택.
///
/// 앱인토스 네비 바·안드로이드 뒤로가기는 기본이 미니앱 종료다.
/// 내부 화면(설정/대시보드 등)이 열려 있으면 먼저 닫고, 루트에서만 [onExit]로 종료한다.
class AppBackDispatcher {
  AppBackDispatcher({
    this.onExit,
    this.canPopNavigator,
    this.popNavigator,
  });

  static final AppBackDispatcher instance = AppBackDispatcher();

  /// 루트에서 뒤로가기 시 미니앱/앱 종료.
  void Function()? onExit;

  /// Flutter [Navigator]에 다이얼로그 등이 쌓여 있는지.
  bool Function()? canPopNavigator;

  void Function()? popNavigator;

  final List<bool Function()> _handlers = [];

  void push(bool Function() handler) {
    _handlers.add(handler);
  }

  void remove(bool Function() handler) {
    _handlers.remove(handler);
  }

  /// 뒤로가기 1회 처리. 처리되면 true.
  bool handleBack() {
    if (canPopNavigator?.call() ?? false) {
      popNavigator?.call();
      return true;
    }

    if (_handlers.isNotEmpty) {
      final handled = _handlers.last();
      if (handled) return true;
    }

    onExit?.call();
    return onExit != null;
  }
}
