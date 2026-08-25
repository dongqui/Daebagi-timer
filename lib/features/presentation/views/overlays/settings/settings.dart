import 'package:flutter/material.dart';

import 'package:catodo/features/presentation/views/overlays/settings/character_setting.dart';
import 'package:catodo/features/presentation/views/dashboard/dashboard.dart';
import 'package:catodo/features/presentation/views/overlays/settings/setting_card.dart';

class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({super.key});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingCard(child: CharacterSettingOverlay()),
          const SizedBox(height: 16),
          SettingCard(child: Dashboard()),
        ],
      ),
    );
  }
}
