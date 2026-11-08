import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/Widgets/lieChart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bookbank/features/home/popup/popup_main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

class DashboardSummary extends StatelessWidget {
  final double totalBalance;
  final double bankBalance;
  final double cashBalance;
  final double incomeTotal;
  final double expenseTotal;
  final double monthlyIncome;
  final double monthlyExpense;
  final List<FlSpot> spots;

  const DashboardSummary({
    super.key,
    required this.totalBalance,
    required this.bankBalance,
    required this.cashBalance,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.spots,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Dialog(
              child: PopupMain(
                totalBalance: totalBalance,
                bankBalance: bankBalance,
                cashBalance: cashBalance,
                incomeTotal: incomeTotal,
                expenseTotal: expenseTotal,
                monthlyIncome: monthlyIncome,
                monthlyExpense: monthlyExpense,
                spots: spots,
              ),
            );
          },
        );
      },
      child: Container(
        height: 155.h,
        padding: EdgeInsets.all(16.r),
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            // ────────── Total Balance ──────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.totalBalance,
                      style: TextStyle(fontSize: AppSize.xs.sp),
                    ),
                    Text(
                      locProvider.formatAmount(totalBalance),
                      style: TextStyle(fontSize: AppSize.l.sp),
                    ),
                  ],
                ),

                // ────────── Line Chart ──────────
                SizedBox(
                  height: 40.h,
                  width: 160.w,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: createSegmentsWithArea(spots),
                      minY: -5000,
                      maxY: 5000,
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 1,
                      maxX: 31,
                      lineTouchData: const LineTouchData(enabled: false),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Divider
            Divider(color: theme.colorScheme.outline),

            // ────────── Money Position ──────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem(
                  context,
                  icon: null,
                  label: loc.validToday,
                  balance: 0,
                  total: totalBalance,
                  locProvider: locProvider,
                ),

                Container(
                  width: 1,
                  height: 55.h,
                  color: theme.colorScheme.outline,
                ),

                _buildBalanceItem(
                  context,
                  icon: Icons.account_balance_rounded,
                  label: loc.bank,
                  balance: bankBalance,
                  total: totalBalance,
                  locProvider: locProvider,
                ),

                Container(
                  width: 1,
                  height: 55.h,
                  color: theme.colorScheme.outline,
                ),

                _buildBalanceItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: loc.cash,
                  balance: cashBalance,
                  total: totalBalance,
                  locProvider: locProvider,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────── Balance item ──────────
  Widget _buildBalanceItem(
    BuildContext context, {
    IconData? icon,
    required String label,
    required double balance,
    required double total,
    required LocalizationProvider locProvider,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 80.w,
      height: 55.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Row(
            children: [
              icon != null
                  ? Icon(
                      icon,
                      size: 16.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    )
                  : SizedBox.shrink(),

              icon != null ? SizedBox(width: 8.w) : SizedBox.shrink(),

              Text(
                label,
                style: TextStyle(
                  fontSize: AppSize.s.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          Text(
            locProvider.formatAmount(balance),
            style: TextStyle(fontSize: AppSize.m.sp),
          ),
        ],
      ),
    );
  }
}
