import 'package:flutter/material.dart';
import 'package:catodo/core/navigation/app_back_dispatcher.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/focus_form/focus_activity_input_widget.dart';
import 'package:catodo/features/presentation/views/focus_form/focus_time_input_widget.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';

class FocusForm extends StatefulWidget {
  const FocusForm({super.key});

  @override
  State<FocusForm> createState() => _FocusFormState();
}

class _FocusFormState extends State<FocusForm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final bool Function() _backHandler;

  @override
  void initState() {
    super.initState();
    _backHandler = () {
      _dismissToHome();
      return true;
    };
    AppBackDispatcher.instance.push(_backHandler);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    AppBackDispatcher.instance.remove(_backHandler);
    _controller.dispose();

    super.dispose();
  }

  void _dismissToHome() {
    _controller.reverse().then((_) {
      TimerManager.instance.cancel();
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 300) {
      // 아래로 스와이프 속도가 300 이상일 때
      _dismissToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onVerticalDragEnd: _handleDragEnd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IntrinsicHeight(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0D1B2A).withValues(alpha: 0.9),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const FocusActivityInputWidget(),
                    const SizedBox(height: 16),
                    const FocusTimeInputWidget(),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        if (FormManager.instance.state.isFocused) {
                          final currentFocus = FocusScope.of(context);
                          currentFocus.unfocus();
                          return;
                        }
                        TimerManager.instance.readyToFocus();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Color(0xFF3A86FF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('시작하기'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
