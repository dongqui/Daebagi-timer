import 'package:flutter/material.dart';
import '../../../viewmodels/timer_state.dart';
import 'package:catodo/features/presentation/views/audio_box.dart';
import 'package:catodo/widgets/background_to_tab_in_stack.dart';

class TimerOverlay extends StatefulWidget {
  const TimerOverlay({super.key});

  @override
  State<TimerOverlay> createState() => _TimerOverlayState();
}

class _TimerOverlayState extends State<TimerOverlay> {
  late TimerState _timerState;
  final _timerManager = TimerManager.instance;

  final GlobalKey audioButtonKey = GlobalKey();
  bool _isAudioBoxVisible = false;
  double audioBoxPositionY = 100.0; // 버튼의 bottom y좌표 저장

  @override
  void initState() {
    super.initState();
    _timerState = _timerManager.state;
    _timerManager.addListener(_handleTimerStateChanged);
  }

  @override
  void dispose() {
    _timerManager.removeListener(_handleTimerStateChanged);
    super.dispose();
  }

  void _handleTimerStateChanged(TimerState state) {
    setState(() {
      _timerState = state;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _toggleAudioBox() {
    final RenderBox renderBox =
        audioButtonKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _isAudioBoxVisible = !_isAudioBoxVisible;
      audioBoxPositionY = position.dy - size.height * 6.5; // 버튼 위로 올라가도록 수정
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (_isAudioBoxVisible)
        BackgroundToTabInStack(
          onTap: _toggleAudioBox,
        ),
      Align(
        alignment: Alignment(0, -0.5),
        child: Text(
          _formatTime(_timerState.focussedTime),
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Positioned(
        bottom: 20,
        right: 20,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Color(0x600D1B2A),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: audioButtonKey,
                color: Color(0xffffffff),
                onPressed: _toggleAudioBox,
                icon: Icon(
                  Icons.music_note,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                color: Color(0xffffffff),
                onPressed: _timerState.status == TimerStatus.running
                    ? _timerManager.pause
                    : _timerManager.start,
                icon: Icon(
                  _timerState.status == TimerStatus.running
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                color: Color(0xffffffff),
                onPressed: () async {
                  TimerManager.instance.pause();
                  final shouldFinish = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('종료'),
                      content: Text('정말로 집중을 그만두시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('아니오'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('예'),
                        ),
                      ],
                    ),
                  );
                  if (shouldFinish == true) {
                    _timerManager.finish();
                  } else {
                    _timerManager.start();
                  }
                },
                icon: Icon(
                  Icons.stop,
                ),
              ),
            ],
          ),
        ),
      ),
      Positioned(
        top: audioBoxPositionY,
        left: 5,
        width: 260,
        child: Offstage(
          offstage: !_isAudioBoxVisible,
          child: const AudioBox(),
        ),
      ),
    ]);
  }
}
