import 'package:flutter/widgets.dart';

import 'package:catodo/features/presentation/viewmodels/audio_controller.dart';
import 'package:catodo/features/presentation/viewmodels/audio_state.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/tds/tds_checkbox.dart';
import 'package:catodo/widgets/tds/tds_glass_panel.dart';

/// 타이머에서 고를 수 있는 백색소음. `assets/sounds/`에 mp3가 있는 것만 노출한다.
const List<AudioType> whiteNoiseTypes = [
  AudioType.rain,
  AudioType.birds,
  AudioType.wave,
  AudioType.fire,
];

String whiteNoiseLabel(AudioType type) => switch (type) {
      AudioType.rain => '빗소리',
      AudioType.birds => '새소리',
      AudioType.wave => '파도소리',
      AudioType.fire => '모닥불',
      AudioType.forest => '숲소리',
      AudioType.wind => '바람소리',
      AudioType.thunder => '천둥소리',
    };

/// 타이머 위에 떠 있는 백색소음 패널.
///
/// [controller]는 타이머 화면이 들고 있다가 넘겨준다 — 패널이 이 위젯 안에서
/// 플레이어를 만들면 패널을 닫을 때 소리가 같이 꺼져버린다.
class AudioBox extends StatefulWidget {
  const AudioBox({super.key, required this.controller});

  final AudioController controller;

  @override
  State<AudioBox> createState() => _AudioBoxState();
}

class _AudioBoxState extends State<AudioBox> {
  @override
  void initState() {
    super.initState();
    AudioManager.instance.addListener(_onAudioStateChanged);
  }

  @override
  void dispose() {
    AudioManager.instance.removeListener(_onAudioStateChanged);
    super.dispose();
  }

  void _onAudioStateChanged(AudioState state, AudioState? previous) {
    if (mounted) setState(() {});
  }

  void _toggle(AudioType type, bool checked) {
    AudioManager.instance.updateWhiteNoise(type.name, checked);
    if (checked) {
      widget.controller.play(type);
    } else {
      widget.controller.stop(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = AudioManager.instance.state.whiteNoise;

    return TdsGlassPanel(
      borderRadius: TdsRadius.panel,
      elevated: true,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '백색소음',
            style: TdsText.bodyBold.copyWith(color: TdsColors.onCanvasStrong),
          ),
          const SizedBox(height: 14),
          for (final type in whiteNoiseTypes) ...[
            TdsCheckbox(
              checked: selected.contains(type.name),
              label: whiteNoiseLabel(type),
              onChanged: (checked) => _toggle(type, checked),
            ),
            if (type != whiteNoiseTypes.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
