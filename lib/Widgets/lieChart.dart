// ────────── Package & Theme Imports ──────────
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ────────── Gradient helpers ──────────
LinearGradient _lineGradient(List<Color> colors) => LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

LinearGradient _areaGradient(List<Color> colors) => LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

// Positive segments: green gradient / Negative segments: red gradient
final _positiveColors = [const Color.fromARGB(255, 18, 168, 55), const Color.fromARGB(166, 18, 168, 55)];
final _negativeColors = [const Color.fromARGB(255, 255, 4, 0), const Color.fromARGB(166, 255, 0, 0)];

// ────────── Create Segments with Area ──────────
List<LineChartBarData> createSegmentsWithArea(List<FlSpot> spots) {
  List<LineChartBarData> segments = [];

  for (int i = 0; i < spots.length - 1; i++) {
    final start = spots[i];
    final end = spots[i + 1];

    // ────────── Check if both points are on the same side of x-axis ──────────
    if ((start.y >= 0 && end.y >= 0) || (start.y < 0 && end.y < 0)) {
      final colors = start.y >= 0 ? _positiveColors : _negativeColors;

      // Add segment to list
      segments.add(
        LineChartBarData(
          spots: [start, end],
          isCurved: true,
          gradient: _lineGradient(colors),
          barWidth: 1.5,
          dotData: FlDotData(show: false),

          belowBarData: BarAreaData(
            show: true,
            gradient: _areaGradient([
              colors.first.withValues(alpha: 0.35),
              colors.last.withValues(alpha: 0.0),
            ]),
          ),
        ),
      );
      continue;
    }

    // ────────── Calculate intersection with x-axis ──────────
    final ratio = start.y / (start.y - end.y);
    final x0 = start.x + (end.x - start.x) * ratio;
    final zeroPoint = FlSpot(x0, 0);

    // ────────── Create first segment ──────────
    final colors1 = start.y >= 0 ? _positiveColors : _negativeColors;

    // ────────── Add first segment to list ──────────
    segments.add(
      LineChartBarData(
        spots: [start, zeroPoint],
        isCurved: true,
        gradient: _lineGradient(colors1),
        barWidth: 1.5,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: _areaGradient([
            colors1.first.withValues(alpha: 0.35),
            colors1.last.withValues(alpha: 0.0),
          ]),
        ),
      ),
    );

    // ────────── Create second segment ──────────
    final colors2 = end.y >= 0 ? _positiveColors : _negativeColors;

    // ────────── Add second segment to list ──────────
    segments.add(
      LineChartBarData(
        spots: [zeroPoint, end],
        isCurved: true,
        gradient: _lineGradient(colors2),
        barWidth: 1.5,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: _areaGradient([
            colors2.first.withValues(alpha: 0.35),
            colors2.last.withValues(alpha: 0.0),
          ]),
        ),
      ),
    );
  }

  return segments;
}
