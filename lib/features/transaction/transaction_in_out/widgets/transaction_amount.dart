import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:bookbank/core/localization/localization_provider.dart';

class TransactionAmount extends StatefulWidget {
  final Function(String?)? onChanged;
  final Function(String?)? onSaved;

  const TransactionAmount({super.key, this.onChanged, this.onSaved});

  @override
  State<TransactionAmount> createState() => _TransactionAmountState();
}

class _TransactionAmountState extends State<TransactionAmount> {
  final TextEditingController controller = TextEditingController();
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                      style: TextStyle(fontSize: 16.sp),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '0.00',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 16.sp,
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

          // ────────── IN/OUT Buttons ──────────
          Row(
            children: [
              // IN Button
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    controller.text = '60';
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.colorScheme.surface),
                ),
                icon: Icon(LucideIcons.rotateCcwClock, size: 16.w),
                label: Text(
                  'latest : ฿ 60.00',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
              SizedBox(width: 12.w),

              // OUT Button
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    controller.text = '20';
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(color: theme.colorScheme.surface),
                ),
                icon: Icon(LucideIcons.star, size: 16.w),
                label: Text(
                  'Popular : ฿ 20.00',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
