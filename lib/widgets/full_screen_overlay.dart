import 'package:flutter/material.dart';

import 'package:catodo/core/navigation/app_back_dispatcher.dart';
import 'package:catodo/theme/tds_colors.dart';

/// 현재 화면 위를 통째로 덮는 오버레이 셸.
///
/// 전환 연출은 없다 — 즉시 나타나고 즉시 사라진다. 예전에는 페이드·스케일이
/// 들어가 있었는데, 닫을 때 뒤 화면이 잠깐 비쳐 멈칫하는 것처럼 보였다.
///
/// 상단 바도 넣지 않는다. 안에 들어오는 화면이 각자 `TdsNavigation`으로 자기
/// 헤더를 그리고, [child]가 받는 닫기 콜백을 원하는 자리에 붙인다.
class FullScreenOverlay extends StatefulWidget {
  const FullScreenOverlay({
    super.key,
    required this.child,
    required this.onClose,
    this.backgroundColor = TdsColors.backgroundLower,
  });

  final Widget Function(BuildContext context, VoidCallback close) child;
  final VoidCallback onClose;
  final Color backgroundColor;

  @override
  State<FullScreenOverlay> createState() => _FullScreenOverlayState();
}

class _FullScreenOverlayState extends State<FullScreenOverlay> {
  late final bool Function() _backHandler;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _backHandler = () {
      _handleClose();
      return true;
    };
    AppBackDispatcher.instance.push(_backHandler);
  }

  @override
  void dispose() {
    AppBackDispatcher.instance.remove(_backHandler);
    super.dispose();
  }

  void _handleClose() {
    if (_isClosing) return;
    _isClosing = true;
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = Positioned.fill(
      child: ColoredBox(
        color: widget.backgroundColor,
        child: widget.child(context, _handleClose),
      ),
    );

    // Stack 안에 놓이면 Positioned.fill이 그대로 먹지만, 아니면 감싸줘야 한다.
    final hasStackAncestor =
        context.findAncestorWidgetOfExactType<Stack>() != null;
    return hasStackAncestor ? overlay : Stack(children: [overlay]);
  }
}
