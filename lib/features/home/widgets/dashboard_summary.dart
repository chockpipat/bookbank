import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/Widgets/lieChart.dart';
import 'package:bookbank/features/home/popup/popup_main.dart';

class DashboardSummary extends StatefulWidget {
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
  State<DashboardSummary> createState() => _DashboardSummaryState();
}

class _DashboardSummaryState extends State<DashboardSummary> {
  bool isBalanceVisible = true;

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
                totalBalance: widget.totalBalance,
                bankBalance: widget.bankBalance,
                cashBalance: widget.cashBalance,
                incomeTotal: widget.incomeTotal,
                expenseTotal: widget.expenseTotal,
                monthlyIncome: widget.monthlyIncome,
                monthlyExpense: widget.monthlyExpense,
                spots: widget.spots,
              ),
            );
          },
        );
      },
      child: Container(
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
                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Text(
                          isBalanceVisible
                              ? locProvider.formatAmount(widget.totalBalance)
                              : '******',
                          style: TextStyle(fontSize: AppSize.l.sp),
                        ),
                        SizedBox(width: 12.w),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              isBalanceVisible = !isBalanceVisible;
                            });
                          },
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: Icon(
                            isBalanceVisible
                                ? LucideIcons.eye
                                : LucideIcons.eyeOff,
                            color: theme.colorScheme.onSurface,
                            size: 18.w,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ────────── Line Chart ──────────
                SizedBox(
                  height: 40.h,
                  width: 160.w,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: createSegmentsWithArea(widget.spots),
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
                  total: widget.totalBalance,
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
                  balance: widget.bankBalance,
                  total: widget.totalBalance,
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
                  balance: widget.cashBalance,
                  total: widget.totalBalance,
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
