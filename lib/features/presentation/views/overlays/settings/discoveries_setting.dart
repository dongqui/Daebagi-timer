import 'package:flutter/material.dart';
import 'package:catodo/core/utils/asset_path.dart';
import 'package:catodo/features/presentation/viewmodels/discovery_state.dart';
import 'package:flame/widgets.dart';
import 'package:flame/sprite.dart';
import 'package:catodo/features/presentation/views/discoveries.dart';
import 'package:catodo/features/data/models/planet.dart';

class DiscoveriesSetting extends StatefulWidget {
  const DiscoveriesSetting({super.key});

  @override
  State<DiscoveriesSetting> createState() => _DiscoveriesSettingState();
}

class _DiscoveriesSettingState extends State<DiscoveriesSetting> {
  @override
  void initState() {
    super.initState();
    DiscoveryManager.instance.addListener(_onDiscoveryStateChanged);
    _loadPlanets();
  }

  @override
  void dispose() {
    DiscoveryManager.instance.removeListener(_onDiscoveryStateChanged);
    super.dispose();
  }

  void _onDiscoveryStateChanged(
      DiscoveryState state, DiscoveryState? oldState) async {
    if (state.planets.length != oldState?.planets.length) {
      setState(() {});
    }
  }

  Future<void> _loadPlanets() async {
    await DiscoveryManager.instance.fetchFinishedPlanets();
  }

  showDiscoveries() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Discoveries(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showDiscoveries,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 128,
            child: Stack(
              children: [
                ...DiscoveryManager.instance.state.planets
                    .asMap()
                    .entries
                    .map((entry) {
                  final i = entry.key;

                  return Positioned(
                    left: i * 50.0,
                    top: 0,
                    child: SizedBox(
                      width: 128,
                      height: 128,
                      child: Image.asset(assetImagePath(entry.value.url)),
                    ),
                  );
                }),
                if (DiscoveryManager.instance.state.planets.length > 4)
                  Positioned(
                    left: 5 * 50.0 + 15, // 마지막 행성 오른쪽
                    top: 48, // 행성 중앙쯤
                    child: Text(
                      '...',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.white,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Image.asset(
          //   '/data/user/0/com.dongqui.focuscope/app_flutter/assets/images/planets/test.gif',
          //   width: 32,
          //   height: 32,
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('찾은 행성:  ${DiscoveryManager.instance.state.planets.length}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(width: 16),
              Text('See more',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF3A86FF))),
            ],
          ),
        ],
      ),
    );
  }
}
