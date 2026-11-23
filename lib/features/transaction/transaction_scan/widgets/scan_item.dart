import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScanItem extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String image;

  const ScanItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────── color indicator ──────────
              Container(
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: title == 'Income' ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
              SizedBox(width: 8.w),

              // ────────── text content ──────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // ────────── image container ──────────
              Container(
                width: 50.w,
                height: 50.h,
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.r),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                child: Image.asset(image, width: 35.w, height: 35.h),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
