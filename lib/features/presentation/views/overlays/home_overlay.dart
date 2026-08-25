import 'package:flutter/material.dart';
import 'package:catodo/features/presentation/viewmodels/timer_state.dart';
import 'package:catodo/widgets/full_screen_overlay.dart';
import 'package:catodo/features/presentation/viewmodels/characater_state.dart';
import 'package:catodo/features/presentation/views/overlays/settings/settings.dart';

class HomeOverlay extends StatefulWidget {
  const HomeOverlay({super.key});

  @override
  HomeOverlayState createState() => HomeOverlayState();
}

class HomeOverlayState extends State<HomeOverlay>
    with SingleTickerProviderStateMixin {
  bool _isSettingsOpen = false;

  @override
  void initState() {
    super.initState();
    CharacterManager.instance.initSelectedCharacter();
    TimerManager.instance.addListenerToStatus(_onTimerStatusChanged);
  }

  @override
  void dispose() {
    TimerManager.instance.removeListenerToStatus(_onTimerStatusChanged);
    super.dispose();
  }

  void _onTimerStatusChanged(TimerStatus status) {
    if (status == TimerStatus.idle &&
        TimerManager.instance.openSettingsOnIdle) {
      TimerManager.instance.openSettingsOnIdle = false;
      setState(() => _isSettingsOpen = true);
    }
  }

  void _toggleSettings() {
    setState(() {
      _isSettingsOpen = !_isSettingsOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: _ShuttleWaveButton(
            onTap: () => TimerManager.instance.setFocus(),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: _toggleSettings,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Center(
                child: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        if (_isSettingsOpen)
          FullScreenOverlay(
            onClose: _toggleSettings,
            backgroundColor: Colors.black,
            child: (context, onClose) => const SettingsOverlay(),
          ),
      ],
    );
  }
}

class _ShuttleWaveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ShuttleWaveButton({required this.onTap});

  @override
  State<_ShuttleWaveButton> createState() => _ShuttleWaveButtonState();
}

class _ShuttleWaveButtonState extends State<_ShuttleWaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (i) {
              final delay = i * 0.33;
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = (_controller.value + delay) % 1.0;
                  final size = 60.0 + progress * 40.0;
                  final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.35;
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[600]!.withOpacity(opacity),
                    ),
                  );
                },
              );
            }),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/icons/shuttle.png',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
