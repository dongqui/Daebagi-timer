import 'package:flutter/widgets.dart';

import 'package:catodo/features/presentation/views/focus_form/form.dart';
import 'package:catodo/widgets/space_backdrop.dart';

/// 집중 준비 화면 오버레이.
///
/// 예전에는 불투명한 검정을 깔아 뒤를 완전히 가렸다. 지금은 [SpaceBackdrop]으로
/// 우주를 그린다 — 뒤의 Flame 월드는 타이머 상태에 따라 홈/타이머가 번갈아 떠서
/// 배경이 화면마다 달라지기 때문이다.
class FocusFormOverlay extends StatelessWidget {
  const FocusFormOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpaceBackdrop(
      moon: true,
      moonAlignment: Alignment(-1.1, -0.45),
      moonScale: 0.5,
      child: FocusForm(),
    );
  }
}
