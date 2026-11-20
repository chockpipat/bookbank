// ────────── Packages ──────────
// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/core/theme/app_theme.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

// ────────── Setting Menu Item ──────────
class settingMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  bool switchValue = false;

  settingMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.switchValue = false,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switchValue
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: theme.colorScheme.onSurface),
                SizedBox(width: 7.w),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Spacer(),

                Transform.scale(
                  scale: 0.6,
                  child: Switch(
                    value: switchValue,
                    onChanged: (value) {},
                    activeThumbColor: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16.sp,
                    color: title == 'Delete Data'
                        ? Colors.red
                        : theme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 7.w),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: title == 'Delete Data'
                          ? Colors.red
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Spacer(),

                  if (title != 'Delete Data')
                    Icon(
                      Icons.chevron_right,
                      size: 18.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                ],
              ),
            ),
          );
  }
}

// ────────── Backing Classes ──────────
class SettingBackingClasses {
  static Widget settingMenuItem({
    required BuildContext context,
    required String title,
    required Widget? child,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 12.h, bottom: 8.h),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          child ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

// ────────── Screen State ──────────
class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.read<LocalizationProvider>().loc;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 115.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ────────── Header ──────────
            Row(
              children: [
                Icon(
                  LucideIcons.settings,
                  size: 24.sp,
                  color: theme.colorScheme.onSurface,
                ),
                SizedBox(width: 12.w),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.settings,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: AppSize.l.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      loc.viewStats,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: AppSize.xs.sp,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ──────────  ──────────
            SettingBackingClasses.settingMenuItem(
              context: context,
              title: 'General',
              child: Column(
                children: [
                  settingMenuItem(
                    title: 'Menu',
                    icon: LucideIcons.menu,
                    onTap: () {},
                  ).build(context),

                  settingMenuItem(
                    title: 'Dark Mode',
                    icon: LucideIcons.moon,
                    onTap: () {},
                    switchValue: true,
                  ).build(context),

                  settingMenuItem(
                    title: 'Edit',
                    icon: LucideIcons.edit,
                    onTap: () {},
                  ).build(context),

                  settingMenuItem(
                    title: 'About',
                    icon: LucideIcons.info,
                    onTap: () {},
                  ).build(context),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // ──────────  ──────────
            SettingBackingClasses.settingMenuItem(
              context: context,
              title: 'Account',
              child: Column(
                children: [
                  settingMenuItem(
                    title: 'Profile',
                    icon: LucideIcons.user,
                    onTap: () {},
                  ).build(context),

                  const Divider(color: Colors.grey),

                  settingMenuItem(
                    title: 'Delete Data',
                    icon: LucideIcons.trash,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Delete Data')),
                      );
                    },
                  ).build(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
