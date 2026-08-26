import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';

import 'package:catodo/core/utils/sprite_loader.dart';
import 'package:catodo/features/data/models/character.dart';
import 'package:catodo/features/presentation/viewmodels/characater_state.dart';
import 'package:catodo/theme/tds_colors.dart';
import 'package:catodo/theme/tds_metrics.dart';
import 'package:catodo/theme/tds_typography.dart';
import 'package:catodo/widgets/tds/tds_button.dart';
import 'package:catodo/widgets/tds/tds_loader.dart';
import 'package:catodo/widgets/tds/tds_navigation.dart';

/// 함께 여행할 캐릭터를 고르는 화면.
///
/// 가운데 캐릭터만 travel 애니메이션으로 크게 움직이고, 양옆은 작게 idle로 대기한다.
class CharacterSelectors extends StatefulWidget {
  const CharacterSelectors({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<CharacterSelectors> createState() => _CharacterSelectorsState();
}

class _CharacterSelectorsState extends State<CharacterSelectors> {
  final _characterManager = CharacterManager.instance;

  late CharacterState _characterState = _characterManager.state;
  PageController? _pageController;
  List<SpriteAnimation> _travelAnimations = const [];
  List<SpriteAnimation> _idleAnimations = const [];
  String _selectedCharacterName = '';

  @override
  void initState() {
    super.initState();
    _characterManager.addListener(_handleCharacterStateChanged);
    _initData();
  }

  @override
  void dispose() {
    _characterManager.removeListener(_handleCharacterStateChanged);
    _pageController?.dispose();
    super.dispose();
  }

  void _handleCharacterStateChanged(CharacterState state, CharacterState? _) {
    if (mounted) setState(() => _characterState = state);
  }

  Future<void> _initData() async {
    await Future.wait([
      _characterManager.initSelectedCharacter(),
      _characterManager.getCharacterList(),
    ]);
    if (!mounted) return;

    _selectedCharacterName = _characterState.selectedCharacter?.name ?? '';

    // 목록에 없으면(선택 이력이 없을 때) 첫 캐릭터부터 보여준다.
    final selectedIndex = _characterState.characterList
        .indexWhere((c) => c.name == _selectedCharacterName);
    _pageController = PageController(
      viewportFraction: 0.4,
      initialPage: selectedIndex < 0 ? 0 : selectedIndex,
    );

    final travel = await _loadAnimations(travelling: true);
    final idle = await _loadAnimations(travelling: false);
    if (!mounted) return;

    setState(() {
      _travelAnimations = travel;
      _idleAnimations = idle;
    });
  }

  Future<List<SpriteAnimation>> _loadAnimations({required bool travelling}) {
    return Future.wait(
      _characterState.characterList.map((character) async {
        final sheet = await loadSprite(
          travelling ? character.travelSprite : character.idleSprite,
        );
        final frames = (travelling ? character.travelframes : character.idleFrames)
            .map((index) => Sprite(
                  sheet,
                  srcSize: Vector2(256, 256),
                  srcPosition: Vector2(index * 256, 0),
                ))
            .toList();
        return SpriteAnimation.spriteList(frames, stepTime: 0.2);
      }),
    );
  }

  /// 지금 가운데에 있는 캐릭터.
  Character? get _selectedCharacter => _characterState.characterList
      .where((c) => c.name == _selectedCharacterName)
      .firstOrNull;

  Future<void> _confirm() async {
    final character = _selectedCharacter;
    if (character != null) {
      await _characterManager.updateCharacter(character);
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _pageController;
    final ready = controller != null &&
        _characterState.characterList.isNotEmpty &&
        _travelAnimations.isNotEmpty &&
        _idleAnimations.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 별을 깔면 캐릭터 스프라이트가 묻혀서 검정으로 둔다.
        const ColoredBox(color: TdsColors.canvas),
        if (!ready)
          const Center(child: TdsLoader())
        else
          Column(
            children: [
              // X는 토스가 오른쪽 위에서 이미 쓰고 있다. 왼쪽에 또 X를 두면
              // 그것과 짝처럼 보여서 미니앱을 닫는 건지 화면을 닫는 건지
              // 헷갈린다. 우리 쪽 화면은 전부 뒤로가기로 통일한다.
              TdsNavigation(onBack: widget.onClose),
              Expanded(child: _buildCarousel(controller)),
              Text(
                _selectedCharacter?.label ?? '',
                style: TdsText.subtitle.copyWith(
                  color: TdsColors.onCanvasStrong,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TdsSpacing.pageMarginS,
                ),
                child: TdsButton(
                  label: '선택',
                  size: TdsButtonSize.xl,
                  fullWidth: true,
                  onPressed: _confirm,
                ),
              ),
              SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
            ],
          ),
      ],
    );
  }

  Widget _buildCarousel(PageController controller) {
    return PageView.builder(
      controller: controller,
      itemCount: _characterState.characterList.length,
      onPageChanged: (index) => setState(
        () => _selectedCharacterName = _characterState.characterList[index].name,
      ),
      itemBuilder: (context, index) {
        final character = _characterState.characterList[index];
        final isSelected = _selectedCharacterName == character.name;
        final animation =
            isSelected ? _travelAnimations[index] : _idleAnimations[index];

        return GestureDetector(
          onTap: () => controller.animateToPage(
            index,
            duration: TdsMotion.base,
            curve: TdsMotion.standard,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: TdsMotion.base,
              curve: TdsMotion.standard,
              width: isSelected ? 128 : 64,
              height: isSelected ? 128 : 64,
              child: SpriteAnimationWidget(
                animation: animation,
                animationTicker: SpriteAnimationTicker(animation),
              ),
            ),
          ),
        );
      },
    );
  }
}
