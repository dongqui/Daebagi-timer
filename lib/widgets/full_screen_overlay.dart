import 'package:catodo/core/navigation/app_back_dispatcher.dart';
import 'package:flutter/material.dart';

class FullScreenOverlay extends StatefulWidget {
  final Widget Function(BuildContext, VoidCallback?) child;
  final Color backgroundColor;
  final VoidCallback onClose;

  const FullScreenOverlay({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    required this.onClose,
  });

  @override
  State<FullScreenOverlay> createState() => _FullScreenOverlayState();
}

class _FullScreenOverlayState extends State<FullScreenOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isClosing = false;
  late final bool Function() _backHandler;

  @override
  void initState() {
    super.initState();
    _backHandler = () {
      _handleClose();
      return true;
    };
    AppBackDispatcher.instance.push(_backHandler);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _fadeAnimation = curve;
    _scaleAnimation = Tween<double>(begin: 1.05, end: 1.0).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    AppBackDispatcher.instance.remove(_backHandler);
    _controller.dispose();
    super.dispose();
  }

  void _handleClose() async {
    if (_isClosing) return;
    setState(() => _isClosing = true);
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStackAncestor =
        context.findAncestorWidgetOfExactType<Stack>() != null;

    Widget overlay = Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            color: widget.backgroundColor,
            child: SafeArea(
              child: Stack(
                children: [
                  // 상단 bar (앱바 스타일, 닫기 버튼 포함)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 64,
                      padding: EdgeInsets.only(top: 16), // 왼쪽 상단 padding
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.topLeft, // 왼쪽 상단 정렬
                      child: GestureDetector(
                        onTap: _handleClose,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          radius: 22,
                          child:
                              Icon(Icons.close, size: 28, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // 스크롤 가능한 내용 (bar 아래에 위치)
                  Positioned.fill(
                    top: 64,
                    child: widget.child(context, _handleClose),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (hasStackAncestor) {
      return overlay;
    } else {
      return Stack(
        children: [overlay],
      );
    }
  }
}
