import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:provider/provider.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryExpenses;
  final double totalExpense;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;
  final Map<String, String> categoryNames;

  const CategoryPieChart({
    super.key,
    required this.categoryExpenses,
    required this.totalExpense,
    required this.categoryIcons,
    required this.categoryColors,
    required this.categoryNames,
  });

  @override
  Widget build(BuildContext context) {
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;
    if (totalExpense <= 0) {
      return Center(
        child: Text(
          loc.notEnoughData,
          style: TextStyle(color: AppColors.grey, fontSize: AppSize.xs.sp),
        ),
      );
    }

    return Row(
      children: [
        // Left: Pie Chart
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 150.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 10.r,
                sections: _buildPieSections(),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Right: Category list
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryExpenses.entries.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final percentage = (amount / totalExpense) * 100;
              final icon = categoryIcons[category] ?? Icons.category;
              final color = categoryColors[category] ?? AppColors.grey;

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryNames[category] ?? category,
                            style: TextStyle(fontSize: AppSize.xs.sp),
                          ),
                          Text(
                            '${locProvider.currencySymbol}${NumberFormat('#,##0.00').format(amount).replaceAll(RegExp(r'\.00$'), '')}',
                            style: TextStyle(
                              fontSize: AppSize.xs.sp,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: AppSize.xs.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final List<PieChartSectionData> sections = [];

    for (final entry in categoryExpenses.entries) {
      final value = entry.value;
      final percentage = (value / totalExpense) * 100;
      final color = categoryColors[entry.key];

      sections.add(
        PieChartSectionData(
          value: value,
          title: '${percentage.toStringAsFixed(1)}%',
          color: color,
          radius: 50.r,
          titleStyle: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }
}
