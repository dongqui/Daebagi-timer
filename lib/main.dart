import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:catodo/core/boot_screen.dart';
import 'package:catodo/core/init_db.dart';
import 'package:catodo/core/navigation/navigator_key.dart';
import 'package:catodo/core/toss_safe_area.dart';
import 'package:catodo/theme/app_theme.dart';
import 'features/presentation/views/main_screen.dart';
import 'features/presentation/views/splash_screen.dart';

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

  // 인트로가 그려진 첫 프레임에 웹 부트 화면(검은 배경)을 걷는다.
  // 토스 앱 안에서는 토스 자체 로딩 화면에 가려 보이지도 않지만,
  // 일반 브라우저에서는 이게 없으면 부팅 중 흰 화면이 뜬다.
  WidgetsBinding.instance.addPostFrameCallback((_) => hideBootScreen());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  /// 인트로가 홈으로 넘겨주는 연출까지 끝났는지.
  /// 초기화 완료와 분리해 둬야 인트로가 중간에 잘리지 않는다.
  bool _splashFinished = false;

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
      if (mounted) setState(() => _isInitialized = true);
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
      // 안전 영역은 화면마다가 아니라 여기서 한 번에 심는다.
      builder: (context, child) => TossSafeArea(child: child ?? const SizedBox()),
      home: _splashFinished
          ? MainScreen()
          : SplashScreen(
              isReady: _isInitialized,
              onFinished: () => setState(() => _splashFinished = true),
            ),
    );
  }
}
