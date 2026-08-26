import 'package:flutter/material.dart';
import 'package:catodo/features/presentation/viewmodels/audio_state.dart';
import 'package:catodo/features/presentation/viewmodels/audio_controller.dart';

final List<AudioType> audioList = [
  AudioType.rain,
  AudioType.birds,
];

String _audioTypeLabel(AudioType type) {
  switch (type) {
    case AudioType.rain:
      return '빗소리';
    case AudioType.birds:
      return '새소리';
    case AudioType.forest:
      return '숲소리';
    case AudioType.ocean:
      return '파도소리';
    case AudioType.wind:
      return '바람소리';
    case AudioType.fire:
      return '모닥불';
    case AudioType.thunder:
      return '천둥소리';
  }
}

class AudioBox extends StatefulWidget {
  const AudioBox({super.key});

  @override
  State<AudioBox> createState() => _AudioBoxState();
}

class _AudioBoxState extends State<AudioBox> {
  final AudioController audioController = AudioController();

  @override
  void initState() {
    super.initState();
    initAudioList();
    audioController.preload(audioList);
  }

  @override
  void dispose() {
    audioController.dispose();
    super.dispose();
  }

  initAudioList() async {
    await AudioManager.instance.getAudioList();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '백색 소음',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: audioList.map((AudioType type) {
              return SizedBox(
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _audioTypeLabel(type),
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Checkbox(
                      activeColor: const Color(0xFF3A86FF),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: AudioManager.instance.state.whiteNoise
                          .contains(type.name),
                      onChanged: (bool? value) {
                        final checked = value ?? false;
                        AudioManager.instance
                            .updateWhiteNoise(type.name, checked);
                        setState(() {});

                        if (checked) {
                          audioController.play(type);
                        } else {
                          audioController.stop(type);
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
