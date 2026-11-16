// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Widgets ──────────
import 'package:bookbank/Widgets/dashboard_range_picker.dart';

// ────────── Data ──────────
import 'package:bookbank/data/database.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

class DashboardChart extends StatefulWidget {
  final List<MyData> transactions;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;
  final Map<String, String> categoryNames;

  const DashboardChart({
    super.key,
    required this.transactions,
    required this.categoryIcons,
    required this.categoryColors,
    required this.categoryNames,
  });

  @override
  State<DashboardChart> createState() => _DashboardChartState();
}

// ────────── Date range button ──────────
class _DateRangeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final bool isEmpty;
  final bool isSelected;

  const _DateRangeButton({
    required this.onPressed,
    this.label,
    this.isEmpty = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? theme.colorScheme.onSurface
              : theme.colorScheme.surfaceContainer,
          foregroundColor: isSelected
              ? theme.colorScheme.surface
              : theme.colorScheme.onSurface,
          minimumSize: Size(30.w, 30.h),
        ),
        icon: isEmpty
            ? Icon(LucideIcons.calendar, size: 18.w)
            : Text(
                label ?? '',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isSelected
                      ? theme.colorScheme.surfaceContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

// ────────── Program card ──────────
class _ProgramCard extends StatelessWidget {
  final double amount;
  final String label;
  final Color color;
  const _ProgramCard({
    required this.amount,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = context.watch<LocalizationProvider>();

    return Expanded(
      child: Container(
        width: double.infinity,
        height: 55.h,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                ),
                SizedBox(width: 4.w),

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  locProvider.formatAmount(amount),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────── Expense Category ──────────

class _ExpenseCategory extends StatelessWidget {
  final IconData icon;
  final String category;
  final double percentage;
  final String amountText;

  const _ExpenseCategory({
    required this.icon,
    required this.category,
    required this.percentage,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp),
          SizedBox(width: 8.w),

          SizedBox(
            width: 90.w,
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          SizedBox(
            width: 100.w,
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 4.h,
              borderRadius: BorderRadius.circular(20.r),
              backgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.1,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          SizedBox(
            width: 70.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  amountText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────── Chart state ──────────

class _DashboardChartState extends State<DashboardChart> {
  static const _incomeColor = Color(0xFF12A837);
  static const _expenseColor = Color(0xFFFF0000);

  DashboardPickMode _mode = DashboardPickMode.day;
  late DateTime _periodStart;
  late DateTime _periodEnd;

  @override
  void initState() {
    super.initState();
    _selectCurrentPeriod();
  }

  // ────────── Period helpers ──────────

  void _selectCurrentPeriod() {
    final now = DateTime.now();
    switch (_mode) {
      case DashboardPickMode.day:
        _periodStart = DateTime(now.year, now.month, now.day);
        _periodEnd = _periodStart;
      case DashboardPickMode.month:
        _periodStart = DateTime(now.year, now.month);
        _periodEnd = DateTime(now.year, now.month + 1, 0);
      case DashboardPickMode.year:
        _periodStart = DateTime(now.year);
        _periodEnd = DateTime(now.year, 12, 31);
    }
  }

  void _onModeChanged(DashboardPickMode mode) {
    setState(() {
      _mode = mode;
      _selectCurrentPeriod();
    });
  }

  Future<void> _openPicker() async {
    final result = await showDashboardRangePicker(
      context,
      mode: _mode,
      initialStart: _periodStart,
      initialEnd: _periodEnd == _periodStart ? null : _periodEnd,
    );
    if (result == null || !mounted) return;

    setState(() {
      switch (_mode) {
        case DashboardPickMode.day:
          _periodStart = DateTime(
            result.start.year,
            result.start.month,
            result.start.day,
          );
          _periodEnd = DateTime(
            result.end.year,
            result.end.month,
            result.end.day,
          );
        case DashboardPickMode.month:
          _periodStart = DateTime(result.start.year, result.start.month);
          _periodEnd = DateTime(result.end.year, result.end.month + 1, 0);
        case DashboardPickMode.year:
          _periodStart = DateTime(result.start.year);
          _periodEnd = DateTime(result.start.year, 12, 31);
      }
    });
  }

  // ────────── Data helpers ──────────

  DateTime? _parseDate(MyData t) {
    final raw = t.date;
    if (raw == null || raw.isEmpty) return null;
    final d = DateTime.tryParse(raw);
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day);
  }

  bool _inRange(MyData t) {
    final d = _parseDate(t);
    if (d == null) return false;
    return !d.isBefore(_periodStart) && !d.isAfter(_periodEnd);
  }

  List<MyData> get _rangeTransactions =>
      widget.transactions.where(_inRange).toList();

  double _sumByType(List<MyData> txs, String type, [DateTime? day]) {
    var sum = 0.0;
    for (final t in txs) {
      if (t.moneyType != type) continue;
      if (day != null) {
        final d = _parseDate(t);
        if (d == null ||
            d.year != day.year ||
            d.month != day.month ||
            d.day != day.day) {
          continue;
        }
      }
      sum += t.amount.toDouble();
    }
    return sum;
  }

  double _sumByTypeInMonth(List<MyData> txs, String type, int year, int month) {
    var sum = 0.0;
    for (final t in txs) {
      if (t.moneyType != type) continue;
      final d = _parseDate(t);
      if (d == null || d.year != year || d.month != month) continue;
      sum += t.amount.toDouble();
    }
    return sum;
  }

  List<DateTime> get _daysInRange {
    final days = <DateTime>[];
    var d = _periodStart;
    while (!d.isAfter(_periodEnd)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }

  // ────────── Chart builders ──────────

  Widget _buildChart(List<MyData> txs) {
    return switch (_mode) {
      DashboardPickMode.day => _buildDayBarChart(txs),
      DashboardPickMode.month => _buildMonthLineChart(txs),
      DashboardPickMode.year => _buildYearBarChart(txs),
    };
  }

  Widget _chartFrame(Widget child) {
    return SizedBox(height: 180.h, width: double.infinity, child: child);
  }

  Widget _emptyChart() {
    final loc = context.read<LocalizationProvider>().loc;
    return _chartFrame(
      Center(
        child: Text(
          loc.notEnoughData,
          style: TextStyle(color: AppColors.grey, fontSize: AppSize.xs.sp),
        ),
      ),
    );
  }

  Widget _legend() {
    final loc = context.read<LocalizationProvider>().loc;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(_incomeColor, loc.income),
        SizedBox(width: 16.w),
        _legendItem(_expenseColor, loc.expense),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 11.sp)),
      ],
    );
  }

  // ────────── Day mode: bar chart per day ──────────

  Widget _buildDayBarChart(List<MyData> txs) {
    final days = _daysInRange;
    if (days.isEmpty) return _emptyChart();

    final incomeValues = <double>[];
    final expenseValues = <double>[];
    var maxY = 0.0;

    for (final day in days) {
      final income = _sumByType(txs, 'income', day);
      final expense = _sumByType(txs, 'expense', day);
      incomeValues.add(income);
      expenseValues.add(expense);
      if (income > maxY) maxY = income;
      if (expense > maxY) maxY = expense;
    }
    if (maxY <= 0) return _emptyChart();

    final interval = (days.length / 8).ceil().clamp(1, days.length).toDouble();
    final rodWidth = days.length > 20 ? 3.0 : 6.0;

    return _chartFrame(
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.15,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22.h,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  if ((index % interval.toInt()) != 0 &&
                      index != days.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '${days[index].day}',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: incomeValues[i],
                    color: _incomeColor,
                    width: rodWidth,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  BarChartRodData(
                    toY: expenseValues[i],
                    color: _expenseColor,
                    width: rodWidth,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ────────── Month mode: line chart per day ──────────

  Widget _buildMonthLineChart(List<MyData> txs) {
    final days = _daysInRange;
    if (days.isEmpty) return _emptyChart();

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    var hasData = false;

    for (var i = 0; i < days.length; i++) {
      final income = _sumByType(txs, 'income', days[i]);
      final expense = _sumByType(txs, 'expense', days[i]);
      if (income > 0 || expense > 0) hasData = true;
      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));
    }
    if (!hasData) return _emptyChart();

    final interval = (days.length / 8).ceil().clamp(1, days.length).toDouble();
    final maxX = days.length <= 1 ? 1.0 : (days.length - 1).toDouble();

    return _chartFrame(
      LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22.h,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  if ((index % interval.toInt()) != 0 &&
                      index != days.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '${days[index].day}',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              color: _incomeColor,
              barWidth: 2,
              isCurved: false,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: expenseSpots,
              color: _expenseColor,
              barWidth: 2,
              isCurved: false,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // ────────── Year mode: bar chart per month ──────────

  Widget _buildYearBarChart(List<MyData> txs) {
    final year = _periodStart.year;
    final loc = context.read<LocalizationProvider>().loc;
    final monthNames = [
      loc.monthJan,
      loc.monthFeb,
      loc.monthMar,
      loc.monthApr,
      loc.monthMay,
      loc.monthJun,
      loc.monthJul,
      loc.monthAug,
      loc.monthSep,
      loc.monthOct,
      loc.monthNov,
      loc.monthDec,
    ];

    final incomeValues = <double>[];
    final expenseValues = <double>[];
    var maxY = 0.0;
    var hasData = false;

    for (var m = 1; m <= 12; m++) {
      final income = _sumByTypeInMonth(txs, 'income', year, m);
      final expense = _sumByTypeInMonth(txs, 'expense', year, m);
      incomeValues.add(income);
      expenseValues.add(expense);
      if (income > maxY) maxY = income;
      if (expense > maxY) maxY = expense;
      if (income > 0 || expense > 0) hasData = true;
    }
    if (!hasData) return _emptyChart();

    return _chartFrame(
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.15,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22.h,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index > 11) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      monthNames[index],
                      style: TextStyle(fontSize: 9.sp),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < 12; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: incomeValues[i],
                    color: _incomeColor,
                    width: 5,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  BarChartRodData(
                    toY: expenseValues[i],
                    color: _expenseColor,
                    width: 5,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ────────── Date range label ──────────

  String _monthAbbr(int month) {
    final loc = context.read<LocalizationProvider>().loc;
    return [
      loc.monthJan,
      loc.monthFeb,
      loc.monthMar,
      loc.monthApr,
      loc.monthMay,
      loc.monthJun,
      loc.monthJul,
      loc.monthAug,
      loc.monthSep,
      loc.monthOct,
      loc.monthNov,
      loc.monthDec,
    ][month - 1];
  }

  int _displayYear(int year) {
    final isThai = context.read<LocalizationProvider>().language.code == 'th';
    return isThai ? year + 543 : year;
  }

  String get _rangeLabel {
    final s = _periodStart;
    final e = _periodEnd;

    switch (_mode) {
      case DashboardPickMode.year:
        return '${_displayYear(s.year)}';
      case DashboardPickMode.month:
        if (s.year == e.year && s.month == e.month) {
          return '${_monthAbbr(s.month)} ${_displayYear(s.year)}';
        }
        if (s.year == e.year) {
          return '${_monthAbbr(s.month)} - ${_monthAbbr(e.month)} ${_displayYear(s.year)}';
        }
        return '${_monthAbbr(s.month)} ${_displayYear(s.year)} - ${_monthAbbr(e.month)} ${_displayYear(e.year)}';
      case DashboardPickMode.day:
        if (s == e ||
            (s.year == e.year && s.month == e.month && s.day == e.day)) {
          return '${s.day} ${_monthAbbr(s.month)} ${_displayYear(s.year)}';
        }
        if (s.year == e.year && s.month == e.month) {
          return '${s.day} - ${e.day} ${_monthAbbr(s.month)} ${_displayYear(s.year)}';
        }
        return '${s.day} ${_monthAbbr(s.month)} - ${e.day} ${_monthAbbr(e.month)} ${_displayYear(e.year)}';
    }
  }

  // ────────── Build ──────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = context.watch<LocalizationProvider>();
    final loc = locProvider.loc;

    final rangeTx = _rangeTransactions;
    final income = _sumByType(rangeTx, 'income');
    final expense = _sumByType(rangeTx, 'expense');
    final net = income - expense;

    // ────────── Expense by category ──────────
    final categoryTotals = <String, double>{};
    var expenseTotal = 0.0;
    for (final t in rangeTx) {
      if (t.moneyType != 'expense') continue;
      final amount = t.amount.toDouble();
      categoryTotals[t.moneyGroup] =
          (categoryTotals[t.moneyGroup] ?? 0) + amount;
      expenseTotal += amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ────────── Header ──────────
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 12.w),

              // ────────── Title and subtitle ──────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.charts,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _mode == DashboardPickMode.day
                        ? loc.chartDay
                        : _mode == DashboardPickMode.month
                            ? loc.chartMonth
                            : loc.chartYear,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // ────────── Date range buttons ──────────
              Row(
                children: [
                  _DateRangeButton(
                    label: 'D',
                    isSelected: _mode == DashboardPickMode.day,
                    onPressed: () => _onModeChanged(DashboardPickMode.day),
                  ),

                  _DateRangeButton(
                    label: 'M',
                    isSelected: _mode == DashboardPickMode.month,
                    onPressed: () => _onModeChanged(DashboardPickMode.month),
                  ),

                  _DateRangeButton(
                    label: 'Y',
                    isSelected: _mode == DashboardPickMode.year,
                    onPressed: () => _onModeChanged(DashboardPickMode.year),
                  ),

                  _DateRangeButton(isEmpty: true, onPressed: _openPicker),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ────────── Chart content ──────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              // color: theme.colorScheme.outline,
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // ────────── Program card ──────────
                    _ProgramCard(
                      amount: income,
                      label: loc.income,
                      color: _incomeColor,
                    ),
                    SizedBox(width: 4.w),

                    _ProgramCard(
                      amount: expense,
                      label: loc.expense,
                      color: _expenseColor,
                    ),
                    SizedBox(width: 4.w),

                    _ProgramCard(
                      amount: net,
                      label: loc.net,
                      color: Colors.blue,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // ────────── Legend ──────────
                _legend(),
                SizedBox(height: 4.h),

                // ────────── Chart ──────────
                _buildChart(rangeTx),
                SizedBox(height: 4.h),

                // ────────── Date range ──────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _rangeLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            loc.expenseCategories,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 8.h),

          // ────────── Expense categories ──────────
          if (sortedCategories.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                loc.notEnoughData,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            ...sortedCategories.map((entry) {
              final groupId = entry.key;
              final amount = entry.value;
              final percentage = expenseTotal > 0 ? amount / expenseTotal : 0.0;

              return _ExpenseCategory(
                icon: widget.categoryIcons[groupId] ?? Icons.category_outlined,
                category: groupId.isEmpty
                    ? loc.anonymous
                    : (widget.categoryNames[groupId] ?? groupId),
                percentage: percentage,
                amountText: locProvider.formatAmount(amount),
              );
            }),
        ],
      ),
    );
  }
}
