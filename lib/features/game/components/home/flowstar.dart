import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

enum FlowStarDirection { left, right }

/// 별똥별이 지나갈 경로.
@immutable
class FlowStarPath {
  const FlowStarPath(this.start, this.end);

  final Vector2 start;
  final Vector2 end;
}

/// 스프라이트 한 변. 화면 밖에서 출발·퇴장시키려고 이만큼 여유를 둔다.
const double _flowStarSize = 128;

/// 화면 밖에서 들어와 대각선으로 흘러 반대편 밖으로 나가는 경로를 만든다.
///
/// 경로 계산이 두 군데로 갈라져 있어서, 리사이즈될 때 방향을 무시한 수평 경로로
/// 덮이는 버그가 있었다. 계산은 이 함수 하나로만 한다.
FlowStarPath buildFlowStarPath({
  required FlowStarDirection direction,
  required Vector2 screen,
  required double startY,
}) {
  final goingRight = direction == FlowStarDirection.right;
  return FlowStarPath(
    Vector2(goingRight ? -_flowStarSize : screen.x, startY),
    // 가로로만 지나가면 별똥별로 보이지 않는다. 흐르면서 아래로 내려가야 한다.
    Vector2(
      goingRight ? screen.x : -_flowStarSize,
      startY + screen.y * 0.4,
    ),
  );
}

class FlowStar extends SpriteComponent with HasGameReference {
  FlowStar(this._direction);

  final FlowStarDirection _direction;
  final Random _random = Random();

  late double _elapsed;
  late double _duration;
  late FlowStarPath _path;

  bool _moving = true;
  double _waitTimer = 0;
  double _waitDuration = 0;

  /// onLoad가 끝나 경로를 계산할 수 있는 상태인가.
  /// [onGameResize]는 스프라이트가 준비되기 전에도 불린다.
  bool _ready = false;

  @override
  Future<void> onLoad() async {
    final spriteSheet =
        await game.images.load('flowstar_${_direction.name}.png');
    sprite = Sprite(spriteSheet);
    size = Vector2.all(_flowStarSize);
    _resetStar();
    _ready = true;
  }

  void _resetStar() {
    _elapsed = 0;
    _duration = 0.7 + _random.nextDouble() * 1.5; // 0.7~2.2초에 걸쳐 흐른다
    _path = buildFlowStarPath(
      direction: _direction,
      screen: game.size,
      startY: _random.nextDouble() * game.size.y,
    );
    position = _path.start.clone();
    _moving = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_moving) {
      _elapsed += dt;
      final t = (_elapsed / _duration).clamp(0.0, 1.0);
      position = _path.start + (_path.end - _path.start) * t;
      if (t >= 1.0) {
        _moving = false;
        _waitDuration = 1.0 + _random.nextDouble() * 8.0; // 1~9초 쉬었다 다시
        _waitTimer = 0;
      }
    } else {
      _waitTimer += dt;
      if (_waitTimer >= _waitDuration) _resetStar();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // 새 화면 크기에 맞는 경로를 다시 잡는다. 스플래시에서 홈으로 넘어올 때
    // 리사이즈가 한 번 일어나므로 여기서 경로를 망가뜨리면 바로 티가 난다.
    if (_ready) _resetStar();
  }
}
