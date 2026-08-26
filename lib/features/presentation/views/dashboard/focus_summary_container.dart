import 'package:flutter/material.dart';
import 'package:catodo/features/presentation/viewmodels/chart_state.dart';

class FocusSummaryContainer extends StatefulWidget {
  const FocusSummaryContainer({super.key});

  @override
  State<FocusSummaryContainer> createState() => _FocusSummaryContainerState();
}

class _FocusSummaryContainerState extends State<FocusSummaryContainer> {
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
    return SizedBox(
      height: 120, // 원하는 높이로 설정
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF171F2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '총 시간\n${_calculateTotalTime()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF171F2A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '세션\n${_calculateSessionCount()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalTime() {
    int totalSeconds = 0;
    for (var session in _state.focusSessions) {
      for (var (_, duration) in session) {
        totalSeconds += duration;
      }
    }

    if (totalSeconds < 60) {
      return '${totalSeconds}초';
    } else if (totalSeconds < 3600) {
      return '${(totalSeconds / 60).round()}분';
    } else {
      int hours = (totalSeconds / 3600).floor();
      int minutes = ((totalSeconds % 3600) / 60).round();
      return '$hours시간 $minutes분';
    }
  }

  String _calculateSessionCount() {
    int count = 0;
    for (var session in _state.focusSessions) {
      count += session.length;
    }
    return count.toString();
  }
}
