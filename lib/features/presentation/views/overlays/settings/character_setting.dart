import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

import 'package:catodo/core/utils/sprite_loader.dart';
import 'package:catodo/features/presentation/viewmodels/characater_state.dart';
import 'package:catodo/features/presentation/views/character_selectors.dart';
import 'package:catodo/theme/tds_colors.dart';

/// 지금 선택된 캐릭터를 보여주는 영역. 누르면 캐릭터를 바꿀 수 있다.
///
/// 기록 화면 상단의 캐릭터 자리에 들어간다.
class CharacterSettingOverlay extends StatefulWidget {
  const CharacterSettingOverlay({
    super.key,
    this.size = 110,
    this.interactive = true,
  });

  /// 캐릭터를 그릴 정사각형 한 변의 길이.
  final double size;

  /// 눌러서 캐릭터를 바꿀 수 있는지. 집중 직전 준비 화면처럼 캐릭터를 보여주기만
  /// 하는 자리에서는 끈다.
  final bool interactive;

  @override
  State<CharacterSettingOverlay> createState() =>
      _CharacterSettingOverlayState();
}

class _CharacterSettingOverlayState extends State<CharacterSettingOverlay> {
  final _characterManager = CharacterManager.instance;

  late CharacterState _characterState = _characterManager.state;
  SpriteAnimation? _idleAnimation;

  @override
  void initState() {
    super.initState();
    _characterManager.addListener(_handleCharacterStateChanged);
    _initData();
  }

  @override
  void dispose() {
    _characterManager.removeListener(_handleCharacterStateChanged);
    super.dispose();
  }

  void _handleCharacterStateChanged(
    CharacterState state,
    CharacterState? previous,
  ) {
    if (!mounted) return;
    setState(() => _characterState = state);

    final changed = state.selectedCharacter?.name !=
        previous?.selectedCharacter?.name;
    if (state.selectedCharacter != null && changed) _loadAnimation();
  }

  Future<void> _initData() async {
    await _characterManager.initSelectedCharacter();
    await _loadAnimation();
  }

  Future<void> _loadAnimation() async {
    final character = _characterState.selectedCharacter;
    if (character == null) return;

    final sheet = await loadSprite(character.idleSprite);
    final frames = character.idleFrames
        .map((index) => Sprite(
              sheet,
              srcSize: Vector2(256, 256),
              srcPosition: Vector2(index * 256, 0),
            ))
        .toList();

    if (!mounted) return;
    setState(() {
      _idleAnimation = SpriteAnimation.spriteList(frames, stepTime: 0.2);
    });
  }

  void _openCharacterSelectors() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: TdsColors.canvas,
        insetPadding: EdgeInsets.zero,
        child: CharacterSelectors(onClose: () => Navigator.of(context).pop()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animation = _idleAnimation;
    if (animation == null) return const SizedBox.shrink();

    final character = Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: SpriteAnimationWidget(
          animation: animation,
          animationTicker: SpriteAnimationTicker(animation),
        ),
      ),
    );

    if (!widget.interactive) return character;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openCharacterSelectors,
      child: character,
    );
  }
}
