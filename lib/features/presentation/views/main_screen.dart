import 'package:flutter/material.dart';
import 'package:catodo/core/navigation/app_back_binding.dart';
import 'package:catodo/core/navigation/app_back_dispatcher.dart';
import 'package:catodo/features/game/game_root.dart';
import 'package:flame/game.dart';
import 'package:catodo/features/game/game_overlay_manager.dart';
import 'package:catodo/features/presentation/views/overlays/timer_overlay/timer_overlay.dart';
import 'package:catodo/features/presentation/views/overlays/home_overlay.dart';
import 'package:catodo/features/presentation/views/overlays/focus_end_overlay.dart';
import 'package:catodo/features/presentation/views/overlays/ready_overlay.dart';
import 'package:catodo/features/presentation/views/overlays/focus_form_overlay.dart';
import 'package:catodo/core/navigation/navigator_key.dart';

class MainScreen extends StatelessWidget {
  final game = GameRoot();

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppBackBinding.ensureStarted(navigatorKey);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        AppBackDispatcher.instance.handleBack();
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              GameWidget(
                game: game,
                overlayBuilderMap: {
                  GameOverlay.home.name: (context, game) => const HomeOverlay(),
                  GameOverlay.timer.name: (context, game) =>
                      const TimerOverlay(),
                  GameOverlay.focusEnd.name: (context, game) =>
                      const FocusEndOverlay(),
                  GameOverlay.ready.name: (context, game) =>
                      const ReadyOverlay(),
                  GameOverlay.form.name: (context, game) =>
                      const FocusFormOverlay(),
                  // GameOverlay.login.name: (context, game) => const LoginScreen(),
                },
                initialActiveOverlays: [GameOverlay.home.name],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
