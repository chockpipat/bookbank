import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/localization/localization_provider.dart';

class CurrencySettingScreen extends StatelessWidget {
  const CurrencySettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.watch<LocalizationProvider>().loc;
    final provider = context.read<LocalizationProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          loc.changeCurrency,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        itemCount: AppCurrency.values.length,
        separatorBuilder: (context, index) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final currency = AppCurrency.values[index];
          final isSelected = provider.currency == currency;

          return Material(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () => provider.setCurrency(currency),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        currency.symbol.trim(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${currency.label} (${currency.code})',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            provider.formatAmount(100),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        LucideIcons.check,
                        color: theme.colorScheme.primary,
                        size: 20.sp,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
