import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/data/db_helper.dart';

class TransactionAmount extends StatefulWidget {
  final Function(String?)? onChanged;
  final Function(String?)? onSaved;

  const TransactionAmount({super.key, this.onChanged, this.onSaved});

  @override
  State<TransactionAmount> createState() => _TransactionAmountState();
}

class _TransactionAmountState extends State<TransactionAmount> {
  final TextEditingController controller = TextEditingController();

  double? _latestAmount;
  double? _popularAmount;

  @override
  void initState() {
    super.initState();
    _loadAmounts();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ────────── Load latest & most-used amounts ──────────
  Future<void> _loadAmounts() async {
    try {
      final transactions = await DatabaseHelper.instance.getAllData();
      if (!mounted || transactions.isEmpty) return;

      // Latest transaction (already ordered by id DESC)
      final latest = transactions.first.amount.toDouble();

      // Most frequently used amount
      final counts = <double, int>{};
      for (final t in transactions) {
        final amount = t.amount.toDouble();
        counts[amount] = (counts[amount] ?? 0) + 1;
      }
      double popular = latest;
      int maxCount = 0;
      counts.forEach((amount, count) {
        if (count > maxCount) {
          maxCount = count;
          popular = amount;
        }
      });

      setState(() {
        _latestAmount = latest;
        _popularAmount = popular;
      });
    } catch (_) {}
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toStringAsFixed(0);
    }
    return amount.toStringAsFixed(2);
  }

  void _applyAmount(double amount) {
    final text = _formatAmount(amount);
    setState(() {
      controller.text = text;
    });
    widget.onChanged?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = context.watch<LocalizationProvider>();
    final loc = locProvider.loc;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ────────── Amount Input ──────────
          Text(
            loc.amount,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),

          // Amount Input
          Container(
            width: double.infinity,
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(fontSize: 12.sp),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '0.00',
                prefixIcon: SizedBox(
                  width: 24.w,
                  child: Center(
                    child: Text(
                      locProvider.currencySymbol,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurface
                      ),
                    ),
                  ),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12.sp,
                ),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              onChanged: widget.onChanged,
              onSaved: widget.onSaved,
            ),
          ),
          SizedBox(height: 8.h),

          // ────────── Quick Amount Buttons ──────────
          if (_latestAmount != null || _popularAmount != null)
            Row(
              children: [
                // Latest Transaction Button
                if (_latestAmount != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _applyAmount(_latestAmount!),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.colorScheme.surface),
                      ),
                      icon: Icon(LucideIcons.rotateCcwClock, size: 16.w),
                      label: Text(
                        '${loc.latest} : ฿ ${_formatAmount(_latestAmount!)}',
                        style: TextStyle(fontSize: 12.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (_latestAmount != null && _popularAmount != null)
                  SizedBox(width: 12.w),

                // Popular Amount Button
                if (_popularAmount != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _applyAmount(_popularAmount!),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.colorScheme.surface),
                      ),
                      icon: Icon(LucideIcons.star, size: 16.w),
                      label: Text(
                        '${loc.popular} : ฿ ${_formatAmount(_popularAmount!)}',
                        style: TextStyle(fontSize: 12.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
