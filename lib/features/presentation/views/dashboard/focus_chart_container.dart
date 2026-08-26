import 'package:flutter/material.dart';
import 'package:catodo/features/presentation/views/dashboard/widgets/charts/focus_chart_per_date_unit.dart';
import 'package:catodo/features/presentation/viewmodels/chart_state.dart';

class FocusChartContainer extends StatefulWidget {
  const FocusChartContainer({super.key});

  @override
  State<FocusChartContainer> createState() => _FocusChartContainerState();
}

class _FocusChartContainerState extends State<FocusChartContainer> {
  ChartState _state = ChartManager.instance.state;

  void _handleChangeState(ChartState state, ChartState? oldState) {
    setState(() {
      _state = state;
    });
  }

  @override
  void initState() {
    super.initState();
    ChartManager.instance.addListener(_handleChangeState);
  }

  @override
  void dispose() {
    ChartManager.instance.removeListener(_handleChangeState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF171F2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ToggleButtons(
                isSelected:
                    List.generate(4, (i) => _state.currentDateUnit.index == i),
                onPressed: (int index) {
                  ChartManager.instance.updateDateUnit(DateUnit.values[index]);
                },
                borderColor: Colors.transparent,
                selectedColor: Color(0xFF3A86FF),
                fillColor: Colors.transparent,
                color: Color(0xFFFFFFFF),
                children: const [
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(
                      child: Text(
                        '일',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(
                      child: Text(
                        '주',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(
                      child: Text(
                        '월',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Center(
                      child: Text(
                        '년',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => ChartManager.instance.movePrevious(),
                  icon: const Icon(Icons.chevron_left_rounded,
                      color: Color(0xFFFFFFFF), size: 32),
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                ),
                Text(
                  ChartManager.instance.getFormattedDateRange(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                IconButton(
                  onPressed: () => ChartManager.instance.moveNext(),
                  icon: const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFFFFFFF), size: 32),
                  visualDensity: VisualDensity.compact,
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
        const FocusChartPerDateUnit(),
      ],
    );
  }
}
