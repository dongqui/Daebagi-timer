import 'package:flutter/material.dart';

import 'package:catodo/core/navigation/app_back_dispatcher.dart';
import 'package:catodo/features/presentation/viewmodels/form_state.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/focus_form/focus_activity_input_widget.dart';
import 'package:catodo/features/presentation/views/focus_form/focus_time_input_widget.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/widgets/tds/tds_bottom_cta.dart';
import 'package:catodo/widgets/tds/tds_button.dart';
import 'package:catodo/widgets/tds/tds_icon_button.dart';
import 'package:catodo/widgets/tds/tds_navigation.dart';

/// 집중을 시작하기 전 무엇을·얼마나 할지 정하는 화면.
///
/// 우주 배경 위에 시트가 올라오는 형태라, 시트만 아래에서 밀어 올리고
/// 배경은 그대로 둔다.
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

  int _duration = FormManager.instance.state.duration;

  @override
  void initState() {
    super.initState();

    _backHandler = () {
      _dismissToHome();
      return true;
    };
    AppBackDispatcher.instance.push(_backHandler);
    FormManager.instance.addListener(_onFormStateChanged);

    _controller = AnimationController(
      duration: TdsMotion.sheet,
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: TdsMotion.emphasized),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    AppBackDispatcher.instance.remove(_backHandler);
    FormManager.instance.removeListener(_onFormStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onFormStateChanged(FocusFormState state) {
    if (!mounted || state.duration == _duration) return;
    setState(() => _duration = state.duration);
  }

  void _dismissToHome() {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.reverse().then((_) => TimerManager.instance.cancel());
  }

  void _handleDragEnd(DragEndDetails details) {
    // 아래로 빠르게 스와이프하면 닫는다.
    if ((details.primaryVelocity ?? 0) > 300) _dismissToHome();
  }

  void _start() {
    FocusManager.instance.primaryFocus?.unfocus();
    FormManager.instance.addLatestActivity();
    TimerManager.instance.readyToFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          TdsNavigation(
            transparent: true,
            onBack: _dismissToHome,
            rightItems: [
              TdsIconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                size: TdsIconButtonSize.l,
                variant: TdsIconButtonVariant.clear,
                color: TdsColors.onCanvasIcon,
                semanticLabel: '기록 보기',
                onPressed: () => TimerManager.instance.goToStats(),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: GestureDetector(
                  onVerticalDragEnd: _handleDragEnd,
                  child: SlideTransition(
                    position: _offsetAnimation,
                    child: _buildSheet(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: TdsColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TdsRadius.sheet),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(child: _SheetHandle()),
          ),
          const FocusActivityInputWidget(),
          const FocusTimeInputWidget(),
          TdsBottomCta(
            gradient: false,
            child: TdsButton(
              label: '시작하기',
              size: TdsButtonSize.xl,
              fullWidth: true,
              onPressed: _duration > 0 ? _start : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: TdsColors.fillNeutralWeak,
        borderRadius: BorderRadius.circular(TdsRadius.full),
      ),
    );
  }
}
