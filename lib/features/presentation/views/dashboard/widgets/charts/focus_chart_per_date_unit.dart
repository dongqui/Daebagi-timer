import 'package:flutter/material.dart';
import 'package:catodo/features/presentation/views/dashboard/widgets/charts/base_chart.dart';
import 'package:catodo/features/presentation/viewmodels/chart_state.dart';

class FocusChartPerDateUnit extends StatefulWidget {
  const FocusChartPerDateUnit({super.key});

  @override
  State<FocusChartPerDateUnit> createState() => _FocusChartPerDateUnitState();
}

class _FocusChartPerDateUnitState extends State<FocusChartPerDateUnit> {
  ChartState _state = ChartManager.instance.state;

  @override
  void initState() {
    super.initState();
    ChartManager.instance.addListener(handleChartStateChange);
  }

  @override
  void dispose() {
    ChartManager.instance.removeListener(handleChartStateChange);
    super.dispose();
  }

  handleChartStateChange(ChartState state, ChartState? oldState) {
    setState(() {
      _state = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseChart(dataList: _state.focusSessions, labels: getLabels());
  }

  List<String> getLabels() {
    if (_state.currentDateUnit == DateUnit.day) {
      return List.generate(24, (index) => index.toString());
    } else if (_state.currentDateUnit == DateUnit.week) {
      return ['월', '화', '수', '목', '금', '토', '일'];
    } else if (_state.currentDateUnit == DateUnit.month) {
      return List.generate(31, (index) => (index + 1).toString());
    } else if (_state.currentDateUnit == DateUnit.year) {
      return List.generate(12, (index) => (index + 1).toString());
    }
    return [];
  }
}
