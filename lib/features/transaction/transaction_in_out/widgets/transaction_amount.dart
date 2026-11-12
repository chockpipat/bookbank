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

          // Amount Input Container
          Container(
            width: double.infinity,
            height: 50.h,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8.r),
              color: theme.colorScheme.surface,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // Currency Symbol
                  Text(
                    locProvider.currencySymbol,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(width: 8.w),

                  // Amount Input Field
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      style: TextStyle(fontSize: 12.sp),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '0.00',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 12.sp,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      onChanged: widget.onChanged,
                      onSaved: widget.onSaved,
                    ),
                  ),
                ],
              ),
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
