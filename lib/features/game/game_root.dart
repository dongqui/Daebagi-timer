import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/home/home_world.dart';
import 'events/game_event_manager.dart';
import 'components/timer/timer_world.dart';
import 'package:catodo/features/data/models/character.dart';

class GameRoot extends FlameGame
    with SingleGameInstance, MultiTouchDragDetector {
  late final HomeWorld homeWorld;
  late final CameraComponent gameCamera;
  late final GameEventManager gameEventManager;
  late final TimerWorld timerWorld;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 7, 7, 7);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 게임 매니저 추가
    gameEventManager = GameEventManager();
    // 게임 월드 설정
    homeWorld = HomeWorld();
    timerWorld = TimerWorld();

    // 카메라 설정
    gameCamera = CameraComponent(world: homeWorld)
      ..viewfinder.anchor = Anchor.topLeft;

    // 컴포넌트 추가
    await addAll([homeWorld, gameCamera, gameEventManager]);

    _warmUpTimerAssets();
  }

  /// 타이머 월드가 쓰는 별 이미지를 미리 캐시에 올려둔다.
  ///
  /// 원본이 2752x2064짜리 세 장이라, 집중을 시작하는 순간 한꺼번에 디코딩하면
  /// 첫 1초가 눈에 띄게 끊긴다. 홈에 머무는 동안 백그라운드로 데워둔다.
  /// 실패해도 `SpaceMap`이 제때 다시 불러오므로 삼켜도 된다.
  void _warmUpTimerAssets() {
    unawaited(() async {
      try {
        await images.loadAll([
          'parallax/stars_top.png',
          'parallax/stars_mid.png',
          'parallax/stars_bot.png',
        ]);
      } catch (e) {
        debugPrint('타이머 배경 미리 로드 실패 (무시): $e');
      }
    }());
  }

  void setCurrentCharacter(Character character) {
    homeWorld.setTraveller(character);
    timerWorld.setTraveller(character);
  }

  addHomeWorld() async {
    if (children.contains(timerWorld)) {
      remove(timerWorld);
    }
    if (!children.contains(homeWorld)) {
      await add(homeWorld);
    }
    gameCamera.world = homeWorld;
  }

  startTimerWorld() async {
    timerWorld.resume();
  }

  pauseTimerWorld() async {
    timerWorld.pause();
  }

  addTimerWorld() async {
    if (children.contains(homeWorld)) {
      remove(homeWorld);
    }
    if (!children.contains(timerWorld)) {
      await add(timerWorld);
    }
    gameCamera.world = timerWorld;
  }
}
