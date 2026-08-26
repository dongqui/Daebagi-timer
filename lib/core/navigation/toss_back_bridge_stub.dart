/// 비웹 빌드용 stub. 앱인토스 뒤로가기 브릿지는 웹에서만 존재한다.
class TossBackBridge {
  static bool get isAvailable => false;

  static void Function()? subscribeBackEvent(void Function() onBack) => null;

  static Future<void> closeView() async {}
}
