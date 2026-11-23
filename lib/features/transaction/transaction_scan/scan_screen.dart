// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/transaction/transaction_scan/widgets/scan_item.dart';
import 'package:bookbank/features/transaction/transaction_scan/widgets/scan_level.dart';

// ────────── Transaction scan widget ──────────
class TransactionScan extends StatefulWidget {
  const TransactionScan({super.key});

  @override
  State<TransactionScan> createState() => _TransactionScanState();
}

// ────────── Transaction scan state ──────────
class _TransactionScanState extends State<TransactionScan> {
  bool _savingsGoalEnabled = false;
  String _selectedScanTest = 'Low';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            LucideIcons.chevronLeft,
            color: theme.colorScheme.onSurface,
            size: 28.sp,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          'Scan images',
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ────────── Scan images header ──────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan images',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _savingsGoalEnabled,
                    onChanged: (value) {
                      setState(() {
                        _savingsGoalEnabled = value;
                      });
                    },
                    activeThumbColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.8,
                    ),
                    inactiveTrackColor: theme.colorScheme.surface,
                    trackOutlineColor: WidgetStateProperty.all(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                    thumbColor: WidgetStateProperty.all(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // ────────── Savings goal content ──────────
            if (_savingsGoalEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ────────── Scan level ──────────
                  Text(
                    'Scan Level',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  ScanLevel(),
                  SizedBox(height: 16.h),

                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // ────────── Scan level options ──────────
                  Row(
                    children: [
                      for (final level in ['Low', 'Medium']) ...[
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _selectedScanTest = level;
                              });
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _selectedScanTest == level
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.surface,
                              foregroundColor: _selectedScanTest == level
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.onSurface,
                              minimumSize: Size(double.infinity, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.r),
                              ),
                            ),
                            child: Text(level),
                          ),
                        ),
                        if (level != 'High') SizedBox(width: 12.w),
                      ],
                    ],
                  ),
                ],
              ),
            SizedBox(height: 16.h),

            Text(
              'Scan items',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),

            ScanItem(
              title: 'Income',
              amount: '\$ 100.00',
              date: '00-00-0000',
              image: 'lib/core/icons/BookBank_Logo 2.png',
            ),
            ScanItem(
              title: 'Expense',
              amount: '\$ 50.00',
              date: '00-00-0000',
              image: 'lib/core/icons/BookBank_Logo 2.png',
            ),
          ],
        ),
      ),
    );
  }
}
