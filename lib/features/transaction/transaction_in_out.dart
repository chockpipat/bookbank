import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionInOut extends StatefulWidget {
  final String title;

  const TransactionInOut({super.key, required this.title});

  @override
  State<TransactionInOut> createState() => _TransactionInOutState();
}

class _TransactionInOutState extends State<TransactionInOut> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.read<LocalizationProvider>().loc;

    return Scaffold(
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────── Header ──────────
              Container(
                width: double.infinity,
                height: 60.h,
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      // ────────── Back Button ──────────
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(LucideIcons.chevronLeft, size: 28.sp),
                      ),
                      SizedBox(width: 18.w),

                      // ────────── Icon Container ──────────
                      Container(
                        width: 35.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // ────────── Title and Balance ──────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: TextStyle(fontSize: 14.sp)),
                          SizedBox(height: 2.h),

                          // Total Balance
                          Text(
                            "฿ 0.00",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // ────────── Info Icon ──────────
                      Icon(
                        LucideIcons.info,
                        size: 18.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 115.h),
                child: Column(
                  children: [
                    Form(
                      child: Text(
                        loc.amount,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
