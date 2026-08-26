import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/theme/app_theme.dart';
import 'package:catodo/widgets/tds/tds_arrow.dart';
import 'package:catodo/widgets/tds/tds_border.dart';
import 'package:catodo/widgets/tds/tds_bottom_cta.dart';
import 'package:catodo/widgets/tds/tds_button.dart';
import 'package:catodo/widgets/tds/tds_checkbox.dart';
import 'package:catodo/widgets/tds/tds_glass_panel.dart';
import 'package:catodo/widgets/tds/tds_icon_button.dart';
import 'package:catodo/widgets/tds/tds_list_header.dart';
import 'package:catodo/widgets/tds/tds_list_row.dart';
import 'package:catodo/widgets/tds/tds_loader.dart';
import 'package:catodo/widgets/tds/tds_navigation.dart';
import 'package:catodo/widgets/tds/tds_numeric_spinner.dart';
import 'package:catodo/widgets/tds/tds_segmented_control.dart';
import 'package:catodo/widgets/tds/tds_text_button.dart';
import 'package:catodo/widgets/tds/tds_text_field.dart';

/// 디자인 기준 프레임. 이 폭에서 넘치면 실기기에서도 넘친다.
const Size _deviceSize = Size(375, 812);

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = _deviceSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('TDS 위젯은 375px 폭에서 넘치지 않는다', () {
    testWidgets('버튼 4가지 크기', (tester) async {
      await _pump(
        tester,
        Column(
          children: [
            for (final size in TdsButtonSize.values)
              TdsButton(
                label: '집중 시작하기',
                size: size,
                fullWidth: true,
                onPressed: () {},
              ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('버튼은 onPressed가 null이면 눌리지 않는다', (tester) async {
      var taps = 0;

      await _pump(
        tester,
        TdsButton(
          label: '시작하기',
          fullWidth: true,
          onPressed: () => taps++,
        ),
      );
      await tester.tap(find.byType(TdsButton));
      expect(taps, 1, reason: '활성 상태에서는 콜백이 불려야 한다');

      await _pump(
        tester,
        const TdsButton(label: '시작하기', fullWidth: true, onPressed: null),
      );
      await tester.tap(find.byType(TdsButton));
      expect(taps, 1, reason: '비활성 상태에서는 콜백이 불리지 않아야 한다');
    });

    testWidgets('시/분/초 스피너 3개가 한 줄에 들어간다', (tester) async {
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              for (final label in ['시간', '분', '초'])
                Expanded(
                  child: Column(
                    children: [
                      Text(label),
                      TdsNumericSpinner(
                        value: 25,
                        max: 59,
                        size: TdsNumericSpinnerSize.xs,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('스피너는 min/max를 넘어서지 않는다', (tester) async {
      var value = 0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => TdsNumericSpinner(
            value: value,
            min: 0,
            max: 2,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );

      // 최소값에서 감소는 막힌다.
      await tester.tap(find.bySemanticsLabel('감소').first);
      await tester.pump();
      expect(value, 0);

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.bySemanticsLabel('증가').first);
        await tester.pump();
      }
      expect(value, 2);
    });

    testWidgets('일/주/월/년 세그먼트', (tester) async {
      var selected = '주';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => TdsSegmentedControl<String>(
            items: const ['일', '주', '월', '년'],
            value: selected,
            size: TdsSegmentedSize.s,
            labelOf: (v) => v,
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('월'));
      await tester.pump();
      expect(selected, '월');
    });

    testWidgets('내비게이션 · 리스트 · 구분선', (tester) async {
      await _pump(
        tester,
        Column(
          children: [
            TdsNavigation(
              title: '집중 기록',
              showBack: false,
              rightItems: [
                TdsIconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () {},
                ),
              ],
            ),
            const TdsBorder.thick(),
            const TdsListHeader(title: '얼마나 집중하실 건가요?'),
            TdsListRow(
              title: '총 집중 시간',
              right: TdsListRow.value('1시간 30분'),
            ),
            const TdsBorder(),
            TdsListRow(
              title: '아주 긴 제목이 들어와도 한 줄로 줄어들어야 한다 정말로 길게 적어본다',
              right: TdsListRow.value('12회'),
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('하단 CTA는 보조 액션까지 함께 놓인다', (tester) async {
      await _pump(
        tester,
        Column(
          children: [
            const Spacer(),
            TdsBottomCta(
              gradient: false,
              lowerItem: TdsTextButton(
                label: '기록 보기',
                size: TdsTextButtonSize.m,
                fullWidth: true,
                onPressed: () {},
              ),
              child: TdsButton(
                label: '한 번 더 집중하기',
                size: TdsButtonSize.xl,
                fullWidth: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('체크박스는 탭하면 값이 뒤집힌다', (tester) async {
      var checked = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => TdsCheckbox(
            checked: checked,
            label: '빗소리',
            onChanged: (v) => setState(() => checked = v),
          ),
        ),
      );

      await tester.tap(find.text('빗소리'));
      await tester.pump();
      expect(checked, isTrue);
    });

    testWidgets('유리 패널 · 로더 · 화살표 · 텍스트 필드', (tester) async {
      await _pump(
        tester,
        Column(
          children: [
            const TdsGlassPanel(
              padding: EdgeInsets.all(16),
              child: TdsLoader(size: 24),
            ),
            const TdsArrow(direction: TdsArrowDirection.left, size: 20),
            TdsTextField(
              label: '어떤 일에 집중하실 건가요?',
              placeholder: '예: 수학 문제 풀기, 영어 단어 외우기',
              onChanged: (_) {},
            ),
          ],
        ),
      );
      // 로더가 도는 동안에도 예외가 없어야 한다.
      await tester.pump(const Duration(milliseconds: 450));
      expect(tester.takeException(), isNull);
    });

    testWidgets('텍스트 필드에 입력하면 onChanged가 불린다', (tester) async {
      String? typed;
      await _pump(
        tester,
        TdsTextField(
          label: '어떤 일에 집중하실 건가요?',
          placeholder: '예: 수학 문제 풀기',
          onChanged: (v) => typed = v,
        ),
      );

      await tester.enterText(find.byType(TextField), '영어 단어 외우기');
      expect(typed, '영어 단어 외우기');
    });
  });
}
