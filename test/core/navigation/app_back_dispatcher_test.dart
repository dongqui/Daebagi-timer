import 'package:catodo/core/navigation/app_back_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBackDispatcher', () {
    test('등록된 핸들러가 있으면 종료하지 않고 핸들러를 실행한다', () {
      var closed = false;
      var exited = false;
      final dispatcher = AppBackDispatcher(
        onExit: () => exited = true,
      );

      dispatcher.push(() {
        closed = true;
        return true;
      });
      dispatcher.handleBack();

      expect(closed, isTrue);
      expect(exited, isFalse);
    });

    test('핸들러가 없으면 onExit를 호출한다', () {
      var exited = false;
      final dispatcher = AppBackDispatcher(
        onExit: () => exited = true,
      );

      dispatcher.handleBack();

      expect(exited, isTrue);
    });

    test('Navigator가 pop 가능하면 핸들러/종료보다 먼저 pop한다', () {
      var popped = false;
      var closed = false;
      var exited = false;
      final dispatcher = AppBackDispatcher(
        canPopNavigator: () => true,
        popNavigator: () => popped = true,
        onExit: () => exited = true,
      );
      dispatcher.push(() {
        closed = true;
        return true;
      });

      dispatcher.handleBack();

      expect(popped, isTrue);
      expect(closed, isFalse);
      expect(exited, isFalse);
    });

    test('remove한 핸들러는 더 이상 호출되지 않는다', () {
      var closed = false;
      var exited = false;
      final dispatcher = AppBackDispatcher(
        onExit: () => exited = true,
      );
      bool handler() {
        closed = true;
        return true;
      }

      dispatcher.push(handler);
      dispatcher.remove(handler);
      dispatcher.handleBack();

      expect(closed, isFalse);
      expect(exited, isTrue);
    });

    test('스택의 마지막 핸들러만 실행한다', () {
      final calls = <String>[];
      final dispatcher = AppBackDispatcher(onExit: () {});

      dispatcher.push(() {
        calls.add('first');
        return true;
      });
      dispatcher.push(() {
        calls.add('second');
        return true;
      });
      dispatcher.handleBack();

      expect(calls, ['second']);
    });
  });
}
