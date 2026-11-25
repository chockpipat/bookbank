// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/transaction/transaction_scan/widgets/scan_authorization.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 62.h,
        actionsPadding: EdgeInsets.symmetric(horizontal: 20.w),

        // ────────── Back button ──────────
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            LucideIcons.chevronLeft,
            color: theme.colorScheme.onSurface,
            size: 28.sp,
          ),
        ),

        // ────────── Title ──────────
        title: Text(
          'Scan images',
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14.sp),
        ),

        // ────────── Info button ──────────
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Scan images',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  content: Text(
                    'Scan images to add them to your library',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              );
            },

            // ────────── Info icon ──────────
            icon: Icon(
              LucideIcons.info,
              color: theme.colorScheme.onSurface,
              size: 18.sp,
            ),
          ),
        ],
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
                  scale: 0.6,
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
                      theme.colorScheme.onSurface,
                    ),
                    thumbColor: WidgetStateProperty.all(
                      theme.colorScheme.onSurface,
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
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  ScanLevel(),
                  SizedBox(height: 24.h),

                  // ────────── Scan authorization ──────────
                  Text(
                    'Transaction permitted',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  ScanAuthorization(),
                  SizedBox(height: 24.h),

                  // ────────── Items detected by the scan ──────────
                  Text(
                    'Items detected by the scan',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface,
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
          ],
        ),
      ),
    );
  }
}
