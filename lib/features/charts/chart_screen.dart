import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Local Imports
import 'package:bookbank/features/charts/widgets/daily_summary_card.dart';
import 'package:bookbank/features/charts/widgets/monthly_chart.dart';
import 'package:bookbank/features/charts/widgets/yearly_chart.dart';
import 'package:bookbank/utils/calculations.dart';
import 'package:bookbank/core/theme/app_theme.dart';

// Database
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<MyData> _transactions = [];
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Daily data
  double _dailyIncome = 0;
  double _dailyExpense = 0;
  double _dailyNet = 0;

  // Monthly data
  List<FlSpot> _monthlySpots = [];
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  double _monthlyNet = 0;

  // Yearly data
  List<FlSpot> _yearlySpots = [];
  double _yearlyIncome = 0;
  double _yearlyExpense = 0;
  double _yearlyNet = 0;

  // Total balance
  double _totalBalance = 0;

  final List<IconData> _availableIcons = [
    Icons.shopping_cart_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.flight_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.sports_soccer_rounded,
    Icons.health_and_safety_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.bar_chart_rounded,
    Icons.fastfood_rounded,
    Icons.coffee_rounded,
    Icons.card_giftcard_rounded,
    Icons.celebration_rounded,
    Icons.favorite_rounded,
    Icons.fitness_center_rounded,
    Icons.filter_hdr_rounded,
    Icons.handyman_outlined,
  ];

  IconData _getIconFromCodePoint(int codePoint) {
    return _availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.add,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllData();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _calculateData();
    });
  }

  void _calculateData() {
    final calc = FinancialCalculations(_transactions);
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final String dateStr = dateFormat.format(_selectedDate);

    // Calculate daily data
    _dailyIncome = calc.dailyIncome(dateStr);
    _dailyExpense = calc.dailyExpense(dateStr);
    _dailyNet = calc.dailyNet(dateStr);

    // Calculate monthly spots
    _monthlySpots = calc.generateDailySpotsForMonth(
      _selectedYear,
      _selectedMonth,
    );

    // Calculate monthly income/expense/net
    _monthlyIncome = calc.monthlyIncomeForDate(_selectedYear, _selectedMonth);
    _monthlyExpense = calc.monthlyExpenseForDate(_selectedYear, _selectedMonth);
    _monthlyNet = calc.monthlyNetForDate(_selectedYear, _selectedMonth);

    // Calculate yearly spots
    _yearlySpots = calc.generateMonthlySpotsForYear(_selectedYear);

    // Calculate yearly income/expense/net
    _yearlyIncome = calc.yearlyIncome(_selectedYear);
    _yearlyExpense = calc.yearlyExpense(_selectedYear);
    _yearlyNet = calc.yearlyNet(_selectedYear);

    // Calculate total balance
    _totalBalance = calc.sumAll().toDouble();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _calculateData();
    });
  }

  void _onMonthChanged(int year, int month) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
      _calculateData();
    });
  }

  void _onYearChanged(int newYear) {
    setState(() {
      _selectedYear = newYear;
      _calculateData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer2<GroupSettingsProvider, LocalizationProvider>(
      builder: (context, groupProvider, locProvider, child) {
        final groupSettings = groupProvider.groupSettings;
        final loc = locProvider.loc;

        final calc = FinancialCalculations(_transactions);
        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

        // All category IDs: configured groups + any category used in transactions
        final categoryIds = <String>{
          ...groupSettings.map((g) => g.groupId),
          ..._transactions
              .where(
                (t) => t.moneyType != 'transfer' && t.moneyGroup.isNotEmpty,
              )
              .map((t) => t.moneyGroup),
        }.toList();

        Map<String, double> expensesFor(double Function(String id) compute) {
          return {
            for (final id in categoryIds) id: compute(id),
          }..removeWhere((key, value) => value <= 0);
        }

        final dailyCategoryExpenses = expensesFor(
          (id) => calc.dailyExpenseByCategory(dateStr, id),
        );
        final monthlyCategoryExpenses = expensesFor(
          (id) => calc.monthlyExpenseByCategory(
            _selectedYear,
            _selectedMonth,
            id,
          ),
        );
        final yearlyCategoryExpenses = expensesFor(
          (id) => calc.yearlyExpenseByCategory(_selectedYear, id),
        );

        final categoryIcons = <String, IconData>{};
        final categoryColors = <String, Color>{};
        final categoryNames = <String, String>{};
        for (final id in categoryIds) {
          final settings = groupProvider.getGroupSettings(id);
          categoryIcons[id] = _getIconFromCodePoint(
            settings?.iconCodePoint ?? Icons.add.codePoint,
          );
          final colorValue = settings?.colorValue ?? 0;
          categoryColors[id] = colorValue != 0
              ? Color(colorValue)
              : Colors.blue;
          categoryNames[id] = settings?.groupName ?? id;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.area_chart,
                        size: 24.sp,
                        color: theme.iconTheme.color,
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.dashboard,
                            style: textTheme.bodyLarge?.copyWith(
                              fontSize: AppSize.l.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            loc.viewStats,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: AppSize.xs.sp,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          loc.totalBalance,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.grey,
                            fontSize: AppSize.xs.sp,
                          ),
                        ),
                        Text(
                          locProvider.formatAmount(_totalBalance),
                          style: textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: AppSize.l.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Container 1 - Daily Summary
                  DailySummaryCard(
                    selectedDate: _selectedDate,
                    dailyIncome: _dailyIncome,
                    dailyExpense: _dailyExpense,
                    dailyNet: _dailyNet,
                    onDateChanged: _onDateChanged,
                    categoryExpenses: dailyCategoryExpenses,
                    categoryIcons: categoryIcons,
                    categoryColors: categoryColors,
                    categoryNames: categoryNames,
                  ),
                  SizedBox(height: 24.h),

                  // Container 2 - Monthly Chart
                  MonthlyChart(
                    selectedYear: _selectedYear,
                    selectedMonth: _selectedMonth,
                    spots: _monthlySpots,
                    onMonthChanged: _onMonthChanged,
                    categoryExpenses: monthlyCategoryExpenses,
                    totalExpense: monthlyCategoryExpenses.values.fold(
                      0.0,
                      (a, b) => a + b,
                    ),
                    categoryIcons: categoryIcons,
                    categoryColors: categoryColors,
                    categoryNames: categoryNames,
                    monthlyIncome: _monthlyIncome,
                    monthlyExpense: _monthlyExpense,
                    monthlyNet: _monthlyNet,
                  ),
                  SizedBox(height: 24.h),

                  // Container 3 - Yearly Chart
                  YearlyChart(
                    selectedYear: _selectedYear,
                    spots: _yearlySpots,
                    onYearChanged: _onYearChanged,
                    categoryExpenses: yearlyCategoryExpenses,
                    totalExpense: yearlyCategoryExpenses.values.fold(
                      0.0,
                      (a, b) => a + b,
                    ),
                    categoryIcons: categoryIcons,
                    categoryColors: categoryColors,
                    categoryNames: categoryNames,
                    yearlyIncome: _yearlyIncome,
                    yearlyExpense: _yearlyExpense,
                    yearlyNet: _yearlyNet,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
