// ────────── Packages & Providers ──────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ────────── localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Widget ──────────
import 'package:bookbank/features/home/widgets/notifications.dart';
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer<LocalizationProvider>(
      builder: (context, locProvider, child) {
        final loc = locProvider.loc;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ────────── App name and logo ──────────
                Row(
                  children: [
                    Image.asset(
                      'lib/core/icons/tangrao_logo1.png',
                      width: 35.w,
                      height: 35.h,
                    ),
                    SizedBox(width: 8.w),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tangrao',
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: 20.sp,
                          ),
                        ),

                        Text(
                          loc.headerDescription,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12.sp,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  children: [
                    // ────────── warn button ──────────
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Notifications(),
                          ),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surface,
                      ),
                      icon: Icon(LucideIcons.bell, size: 18.sp),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
