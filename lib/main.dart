import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:catodo/core/boot_screen.dart';
import 'package:catodo/core/init_db.dart';
import 'package:catodo/core/navigation/navigator_key.dart';
import 'package:catodo/theme/app_theme.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'features/presentation/views/main_screen.dart';

export 'package:catodo/core/navigation/navigator_key.dart' show navigatorKey;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 웹뷰 환경에서는 Screen Wake Lock API가 없을 수 있다.
  // 실패해도 앱 실행은 계속되어야 하므로 삼켜준다.
  try {
    await WakelockPlus.enable();
  } catch (e) {
    debugPrint('Wakelock 활성화 실패 (무시): $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await initDB();
    } catch (e, st) {
      debugPrint('앱 초기화 실패: $e\n$st');
    } finally {
      if (!mounted) return;
      setState(() => _isInitialized = true);

      // 홈이 실제로 그려진 다음 프레임에 인트로를 걷는다.
      //
      // 인트로는 Dart 화면이 아니라 `web/index.html`이 그린다. 같은 그림을 양쪽에
      // 두고 넘기면 그 경계에서 깜빡였기 때문에, 한 장으로 두고 준비가 끝날 때까지
      // 덮어두는 쪽을 택했다. 네이티브에서는 OS 런치 스크린이 그 역할을 한다.
      WidgetsBinding.instance.addPostFrameCallback((_) => hideBootScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // 웹에서는 이 값이 곧 브라우저 탭 제목이 된다. index.html의 <title>과 맞춘다.
      title: '대박이 타이머',
      // TODO: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#localizing-for-ios-updating-the-ios-app-bundle
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      // 저장소가 열리기 전에는 화면을 만들지 않는다. 게임과 오버레이가 곧바로
      // 저장소를 찌르기 때문이다. 이 동안은 인트로가 화면을 덮고 있다.
      home: _isInitialized
          ? MainScreen()
          : const ColoredBox(color: TdsColors.canvas),
    );
  }
}
