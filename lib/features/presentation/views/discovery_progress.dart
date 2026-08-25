import 'package:flutter/material.dart';
import 'package:catodo/core/utils/asset_path.dart';
import 'package:catodo/widgets/progressbar.dart';

class _ProgressMessage {
  final double threshold;
  final String message;
  const _ProgressMessage(this.threshold, this.message);
}

class DiscoveryProgress extends StatefulWidget {
  final double progress;
  final double? addedProgress;
  final String travelerImage;
  final String planetImage;
  const DiscoveryProgress({
    super.key,
    required this.progress,
    this.addedProgress,
    required this.travelerImage,
    required this.planetImage,
  });

  @override
  State<DiscoveryProgress> createState() => _DiscoveryProgressState();
}

class _DiscoveryProgressState extends State<DiscoveryProgress> {
  late double _displayedProgress;

  final List<_ProgressMessage> progressMessages = const [
    _ProgressMessage(0.0, "행성이 희미하게 감지됩니다..."),
    _ProgressMessage(0.2, "행성의 윤곽이 보이기 시작합니다."),
    _ProgressMessage(0.5, "행성이 점점 선명해집니다!"),
    _ProgressMessage(0.8, "거의 다 왔어요!"),
    _ProgressMessage(1.0, "행성을 발견했습니다!"),
  ];

  @override
  void initState() {
    super.initState();
    _displayedProgress = widget.progress + (widget.addedProgress ?? 0);
  }

  @override
  void didUpdateWidget(covariant DiscoveryProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.addedProgress != oldWidget.addedProgress &&
        widget.addedProgress != 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _displayedProgress += widget.addedProgress ?? 0;
          });
        }
      });
    }
  }

  String getProgressMessage(double progress) {
    for (int i = progressMessages.length - 1; i >= 0; i--) {
      if (progress >= progressMessages[i].threshold) {
        return progressMessages[i].message;
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final double planetSize = 256;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: widget.progress, end: _displayedProgress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, animatedProgress, child) {
        final String progressMessage = getProgressMessage(animatedProgress);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 36),
            SizedBox(
              width: planetSize,
              height: planetSize,
              child: Stack(
                children: [
                  // 행성 이미지 (아래)
                  Image.asset(
                    assetImagePath(widget.planetImage),
                    width: planetSize,
                    height: planetSize,
                    fit: BoxFit.cover,
                  ),
                  // progress에 따라 위에서 블랙으로 덮기
                  Container(
                    width: planetSize,
                    height: planetSize,
                    color: Colors.black.withOpacity(animatedProgress < 0.15
                        ? 0.85
                        : 1.0 - animatedProgress * 0.3),
                  ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final progressWidth =
                    (constraints.maxWidth - 96).clamp(120.0, 256.0);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      assetImagePath(widget.travelerImage),
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        const Text(''),
                        CustomPaint(
                          size: Size(progressWidth, 20),
                          painter:
                              ProgressBarPainter(progress: animatedProgress),
                        ),
                        Text(
                          '${(animatedProgress * 100).toStringAsFixed(animatedProgress < 0.1 ? 2 : 1)}%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Image.asset(
                      assetImagePath('planet.png'),
                      width: 32,
                      height: 32,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              progressMessage,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
