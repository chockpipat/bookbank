import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/transaction/transaction_in_out/widgets/transaction_amount.dart';
import 'package:bookbank/features/transaction/transaction_in_out/widgets/transaction_note.dart';

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
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                title: Text("Info"),
                                content: Text("This is an info dialog"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Close"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(LucideIcons.info, size: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 115.h),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TransactionAmount(),
                      SizedBox(height: 18.h),
                      TransactionNote(),
                      Text('Test')
                    ],
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
