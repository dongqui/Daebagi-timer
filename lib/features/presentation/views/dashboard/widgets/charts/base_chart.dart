import 'package:catodo/extensions/index.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:catodo/features/presentation/views/dashboard/widgets/legends_list_widget.dart';
import 'package:catodo/features/presentation/viewmodels/chart_state.dart';
import 'dart:math';

extension DurationExtension on int {
  String toReadableDuration() {
    if (this < 60) {
      return '${this}초';
    } else if (this < 3600) {
      return '${(this / 60).toStringAsFixed(1)}분';
    } else {
      return '${(this / 3600).toStringAsFixed(1)}시간';
    }
  }
}

class BaseChart extends StatelessWidget {
  final List<String> labels;
  final List<List<ActivityTimeTuple>> dataList;
  late final Map<String, Color> colors;
  late final List<String> activities;
  late final double maxValue;
  late final String displayUnit;
  BaseChart({
    super.key,
    required this.dataList,
    required this.labels,
  }) {
    // assert(labels.length == dataList.length,
    //     'labels.length must be equal to dataList.length');

    activities = <String>{
      for (final series in dataList)
        for (final (key, _) in series) key,
    }.toList();

    colors = {
      for (var i = 0; i < activities.length; i++)
        activities[i]: _generateDistinctColor(i, activities.length),
    };

    maxValue = _calculateMaxValueAndUnit();
  }

  static Color _generateDistinctColor(int index, int total) {
    // Hue는 0 ~ 360 사이에서 균등 분포
    final hue = (360.0 * index / total) % 360;

    // 채도(Saturation), 명도(Lightness)는 일정하게 고정
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.55).toColor();
  }

  BarChartGroupData generateGroupData(List<ActivityTimeTuple> series, int x) {
    if (series.isEmpty) {
      return BarChartGroupData(
        x: x,
        groupVertically: true,
        barRods: [],
        showingTooltipIndicators: [],
      );
    }

    double fromY = 0;
    double previousValue = 0;
    List<BarChartRodData> barRods = [];

    int index = 0;

    for (var data in series) {
      final name = data.$1;
      final value = data.$2;
      bool isLast = index == series.length - 1;

      if (index++ > 0) {
        fromY += previousValue;
      }
      previousValue = value.toDouble();

      barRods.add(BarChartRodData(
        borderRadius: isLast
            ? BorderRadius.only(
                topLeft: Radius.circular(4), topRight: Radius.circular(4))
            : BorderRadius.circular(0),
        fromY: fromY,
        toY: fromY + value,
        color: colors[name] ?? Colors.grey,
        width: 10,
      ));
    }

    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: barRods,
      showingTooltipIndicators: [barRods.length - 1],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= labels.length) {
      return const SizedBox.shrink();
    }
    final name = labels[value.toInt()];

    return SideTitleWidget(
      meta: meta,
      child:
          Text(name, style: TextStyle(fontSize: 12, color: Color(0xffffffff))),
    );
  }

  double _calculateMaxValueAndUnit() {
    double maxSeconds = 0;

    // 각 시리즈의 총합 계산
    for (var series in dataList) {
      double seriesTotal = 0;
      for (var (_, value) in series) {
        seriesTotal += value;
      }
      maxSeconds = max(maxSeconds, seriesTotal);
    }

    return maxSeconds;
  }

  /// 주어진 group index의 총 시간을 초 단위로 반환
  int getGroupTotalSeconds(int groupIndex) {
    if (groupIndex < 0 || groupIndex >= dataList.length) return 0;
    return dataList[groupIndex].fold<int>(0, (sum, tuple) => sum + tuple.$2);
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              getGroupTotalSeconds(groupIndex).toReadableDuration(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  BarChart get barChart => BarChart(
        BarChartData(
          alignment: labels.length <= 12
              ? BarChartAlignment.spaceBetween
              : BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            topTitles: AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomTitles,
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barTouchData: barTouchData,
          barGroups: dataList.isEmpty
              ? []
              : dataList
                  .mapWithIndex(
                      (series, index) => generateGroupData(series, index))
                  .toList(),
          maxY: max(maxValue * 1.5, 1.0),
        ),
      );
  @override
  Widget build(BuildContext context) {
    const int activitiesHeight = 14;

    if (activities.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width + 200,
        height: MediaQuery.of(context).size.width / 1.6 + activitiesHeight,
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (activities.isNotEmpty)
            LegendsListWidget(
                legends: activities
                    .map((activity) => Legend(activity, colors[activity]!))
                    .toList()),
          labels.length <= 12
              ? AspectRatio(
                  aspectRatio: 1.6,
                  child: barChart,
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width + 200,
                    height: MediaQuery.of(context).size.width / 1.6,
                    child: barChart,
                  ),
                ),
        ],
      ),
    );
  }
}
