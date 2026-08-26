import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:catodo/core/boot_screen.dart';
import 'package:catodo/core/init_db.dart';
import 'package:catodo/core/navigation/navigator_key.dart';
import 'package:catodo/theme/app_theme.dart';
import 'features/presentation/views/splash_screen.dart';
import 'features/presentation/views/main_screen.dart';
import 'features/presentation/viewmodels/resource_version_state.dart';

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

  // 첫 프레임이 실제로 그려진 뒤에 웹 부트 화면을 걷는다.
  // 더 일찍 걷으면 엔진이 아직 아무것도 안 그린 순간이 드러난다.
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
      await initVersion();
    } catch (e, st) {
      debugPrint('앱 초기화 실패: $e\n$st');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
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
      home: _splashFinished
          ? MainScreen()
          : SplashScreen(
              isReady: _isInitialized,
              onFinished: () => setState(() => _splashFinished = true),
            ),
    );
  }
}

Future<void> initVersion() async {
  if (ResourceVersionManager.instance.state.version == null) {
    await ResourceVersionManager.instance.initVersion();
  }
}

Future<void> versionCheck() async {
  final needsUpdate =
      await ResourceVersionManager.instance.checkVersionUpdate();

  if (needsUpdate) {
    // 버전 업데이트가 필요할 때 dialog 표시
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('업데이트 필요'),
          content: Text('새로운 리소스가 있습니다. 리소스를 다운로드 받으시겠어요?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('나중에'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ResourceVersionManager.instance.updateResources();
                // 업데이트 로직 구현
              },
              child: Text('업데이트'),
            ),
          ],
        );
      },
    );
  }
}
