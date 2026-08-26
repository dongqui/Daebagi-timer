import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/features/game/components/home/flowstar.dart';

void main() {
  final screen = Vector2(375, 812);

  group('별똥별 경로', () {
    test('오른쪽 방향은 화면 왼쪽 밖에서 들어와 오른쪽 끝으로 나간다', () {
      final path = buildFlowStarPath(
        direction: FlowStarDirection.right,
        screen: screen,
        startY: 100,
      );

      expect(path.start.x, lessThan(0), reason: '화면 밖에서 들어와야 한다');
      expect(path.end.x, screen.x);
    });

    test('왼쪽 방향은 오른쪽 끝에서 들어와 화면 왼쪽 밖으로 나간다', () {
      final path = buildFlowStarPath(
        direction: FlowStarDirection.left,
        screen: screen,
        startY: 100,
      );

      expect(path.start.x, screen.x);
      expect(path.end.x, lessThan(0));
    });

    test('가로로만 흐르지 않고 아래로 내려간다', () {
      // 리사이즈될 때 수평 경로로 덮이던 버그가 있었다.
      for (final direction in FlowStarDirection.values) {
        final path = buildFlowStarPath(
          direction: direction,
          screen: screen,
          startY: 100,
        );

        expect(
          path.end.y,
          greaterThan(path.start.y),
          reason: '$direction 방향이 수평이다',
        );
        expect(path.end.y - path.start.y, closeTo(screen.y * 0.4, 0.01));
      }
    });

    test('시작 y는 넘겨준 값을 그대로 쓴다', () {
      final path = buildFlowStarPath(
        direction: FlowStarDirection.right,
        screen: screen,
        startY: 42,
      );

      expect(path.start.y, 42);
    });

    test('화면 크기가 바뀌면 경로도 따라 바뀐다', () {
      final small = buildFlowStarPath(
        direction: FlowStarDirection.right,
        screen: Vector2(375, 812),
        startY: 0,
      );
      final large = buildFlowStarPath(
        direction: FlowStarDirection.right,
        screen: Vector2(768, 1024),
        startY: 0,
      );

      expect(large.end.x, greaterThan(small.end.x));
      expect(large.end.y, greaterThan(small.end.y));
    });
  });
}
