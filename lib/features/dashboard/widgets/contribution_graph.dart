import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/app_localizations.dart';
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/data/database.dart';

class ContributionGraph extends StatefulWidget {
  final List<MyData> transactions;

  const ContributionGraph({super.key, required this.transactions});

  @override
  State<ContributionGraph> createState() => _ContributionGraphState();
}

class _DayTotals {
  double income = 0;
  double expense = 0;

  bool get hasTransactions => income != 0 || expense != 0;
  double get net => income - expense;
}

class _ContributionGraphState extends State<ContributionGraph> {
  static const Color _incomeColor = Color(0xFF12A837);
  static const Color _expenseColor = Color(0xFFFF0000);

  int _selectedYear = DateTime.now().year;
  bool _yearPickedByUser = false;

  int get _latestTransactionYear {
    int? year;
    for (final transaction in widget.transactions) {
      final date = _parseDate(transaction);
      if (date != null && (year == null || date.year > year)) {
        year = date.year;
      }
    }
    return year ?? DateTime.now().year;
  }

  int get _displayYear =>
      _yearPickedByUser ? _selectedYear : _latestTransactionYear;

  @override
  void didUpdateWidget(covariant ContributionGraph oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_yearPickedByUser) {
      _selectedYear = _latestTransactionYear;
      return;
    }

    final minYear = _minYear;
    final maxYear = _maxYear;
    if (_selectedYear < minYear) {
      _selectedYear = minYear;
    } else if (_selectedYear > maxYear) {
      _selectedYear = maxYear;
    }
  }

  // ────────── Date helpers ──────────

  DateTime? _parseDate(MyData transaction) {
    final raw = transaction.date;
    if (raw == null || raw.isEmpty) return null;

    final date = DateTime.tryParse(raw);
    if (date == null) return null;

    return DateTime(date.year, date.month, date.day);
  }

  int get _minYear {
    var year = DateTime.now().year;
    for (final transaction in widget.transactions) {
      final date = _parseDate(transaction);
      if (date != null && date.year < year) year = date.year;
    }
    return year;
  }

  int get _maxYear {
    var year = DateTime.now().year;
    for (final transaction in widget.transactions) {
      final date = _parseDate(transaction);
      if (date != null && date.year > year) year = date.year;
    }
    return year;
  }

  List<int> get _availableYears {
    final minYear = _minYear;
    final maxYear = _maxYear;
    return List.generate(maxYear - minYear + 1, (index) => maxYear - index);
  }

  // ────────── Data helpers ──────────

  Map<DateTime, _DayTotals> _dailyTotals(int year) {
    final totals = <DateTime, _DayTotals>{};

    for (final transaction in widget.transactions) {
      final type = transaction.moneyType;
      if (type != 'income' && type != 'expense') continue;

      final date = _parseDate(transaction);
      if (date == null || date.year != year) continue;

      final day = DateTime(date.year, date.month, date.day);
      final entry = totals.putIfAbsent(day, () => _DayTotals());

      if (type == 'income') {
        entry.income += transaction.amount.toDouble();
      } else {
        entry.expense += transaction.amount.toDouble();
      }
    }

    return totals;
  }

  DateTime _yearStart(int year) {
    final janFirst = DateTime(year, 1, 1);
    return janFirst.subtract(Duration(days: janFirst.weekday % 7));
  }

  List<List<DateTime?>> _columnsForYear(int year) {
    final start = _yearStart(year);
    final lastDay = DateTime(year, 12, 31);
    final daysToAdd = (6 - (lastDay.weekday % 7) + 7) % 7;
    final end = lastDay.add(Duration(days: daysToAdd));

    final columns = <List<DateTime?>>[];
    var cursor = start;

    while (!cursor.isAfter(end)) {
      final column = <DateTime?>[];
      for (var index = 0; index < 7; index++) {
        final day = cursor.add(Duration(days: index));
        column.add(day.year == year ? day : null);
      }
      columns.add(column);
      cursor = cursor.add(const Duration(days: 7));
    }

    return columns;
  }

  String _monthLabel(AppLocalizations loc, int month) {
    return switch (month) {
      1 => loc.monthJan,
      2 => loc.monthFeb,
      3 => loc.monthMar,
      4 => loc.monthApr,
      5 => loc.monthMay,
      6 => loc.monthJun,
      7 => loc.monthJul,
      8 => loc.monthAug,
      9 => loc.monthSep,
      10 => loc.monthOct,
      11 => loc.monthNov,
      _ => loc.monthDec,
    };
  }

  List<String?> _monthLabels(
    List<List<DateTime?>> columns,
    int year,
    AppLocalizations loc,
  ) {
    final labels = List<String?>.filled(columns.length, null);
    final start = _yearStart(year);

    for (var month = 1; month <= 12; month++) {
      final monthStart = DateTime(year, month, 1);
      final columnIndex = monthStart.difference(start).inDays ~/ 7;
      if (columnIndex >= 0 &&
          columnIndex < columns.length &&
          labels[columnIndex] == null) {
        labels[columnIndex] = _monthLabel(loc, month);
      }
    }

    return labels;
  }

  Color _colorFor(
    DateTime? day,
    Map<DateTime, _DayTotals> totals,
    Color emptyColor,
  ) {
    if (day == null) return Colors.transparent;

    final total = totals[day];
    if (total == null || !total.hasTransactions) return emptyColor;

    return total.expense > total.income ? _expenseColor : _incomeColor;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  // ────────── Details dialog ──────────
  void _showDayDetails(DateTime day, _DayTotals? total) {
    final locProvider = context.read<LocalizationProvider>();
    final loc = locProvider.loc;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          title: Text(_formatDate(day), style: TextStyle(fontSize: 16.sp)),
          content: total == null || !total.hasTransactions
              ? Text(
                  loc.noRecord,
                  style: TextStyle(
                    fontSize: AppSize.base.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _detailRow(
                      loc.income,
                      locProvider.formatAmount(total.income),
                      _incomeColor,
                    ),
                    SizedBox(height: 8.h),

                    _detailRow(
                      loc.expense,
                      locProvider.formatAmount(total.expense),
                      _expenseColor,
                    ),
                    SizedBox(height: 8.h),

                    _detailRow(
                      loc.net,
                      locProvider.formatAmount(total.net),
                      total.net >= 0 ? _incomeColor : _expenseColor,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _detailRow(String label, String amount, Color color) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),

        Text(label, style: TextStyle(fontSize: AppSize.base.sp)),
        const Spacer(),

        Text(
          amount,
          style: TextStyle(
            fontSize: AppSize.base.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ────────── Year picker ──────────
  Future<void> _pickYear() async {
    final loc = context.read<LocalizationProvider>().loc;
    final years = _availableYears;

    final selectedYear = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          title: Text(loc.selectYear, style: TextStyle(fontSize: 16.sp)),
          content: SizedBox(
            width: double.maxFinite,
            height: 320.h,
            child: ListView.separated(
              itemCount: years.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final year = years[index];
                final isSelected = year == _displayYear;

                return ListTile(
                  dense: true,
                  title: Text('$year', style: TextStyle(fontSize: 15.sp)),
                  trailing: isSelected
                      ? Icon(
                          LucideIcons.check,
                          size: 18.sp,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(dialogContext, year),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null && mounted) {
      setState(() {
        _yearPickedByUser = true;
        _selectedYear = selectedYear;
      });
    }
  }

  Widget _yearButton() {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: _pickYear,
      icon: Icon(LucideIcons.calendar, size: 16.sp),
      label: Text('$_displayYear'),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ────────── Build ──────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationProvider>().loc;

    final year = _displayYear;
    final totals = _dailyTotals(year);
    final columns = _columnsForYear(year);
    final monthLabels = _monthLabels(columns, year, loc);

    final cellSize = 13.w;
    final gap = 3.w;
    final pitch = cellSize + gap;
    final emptyColor = theme.colorScheme.surfaceContainer;
    final graphHeight = 14.h + 4.h + (7 * pitch) + 4.h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.contributionGraph,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14.sp,
              ),
            ),
            Align(alignment: Alignment.centerRight, child: _yearButton()),
          ],
        ),
        SizedBox(height: 8.h),

        SizedBox(
          height: graphHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ────────── Month Labels ──────────
                SizedBox(
                  height: 14.h,
                  child: Row(
                    children: [
                      for (var index = 0; index < columns.length; index++)
                        SizedBox(
                          width: pitch,
                          child: monthLabels[index] == null
                              ? const SizedBox.shrink()
                              : Text(
                                  monthLabels[index]!,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    height: 1,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // ────────── Contribution Grid ──────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final column in columns)
                      Column(
                        children: [
                          for (final day in column)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: day == null
                                  ? null
                                  : () => _showDayDetails(day, totals[day]),
                              child: Padding(
                                padding: EdgeInsets.all(gap / 2),
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: _colorFor(day, totals, emptyColor),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
