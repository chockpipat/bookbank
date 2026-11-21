// ────────── Packages & Providers ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';
import 'package:bookbank/features/menu/about/privacy_policy_dialog.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/menu/about/about_sgreen.dart';
import 'package:bookbank/features/menu/editGroup/editGroup_sgreen.dart';
import 'package:bookbank/features/setting/widgets/manage_notes_screen.dart';
import 'package:bookbank/features/setting/widgets/currency_setting_screen.dart';
import 'package:bookbank/features/setting/widgets/language_setting_screen.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/core/theme/app_theme.dart';

import 'package:bookbank/data/db_helper.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

// ────────── Setting Menu Item ──────────
class SettingMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSwitchChanged;
  bool switchValue = false;
  String? showData;

  SettingMenuItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.onSwitchChanged,
    this.switchValue = false,
    this.showData,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.read<LocalizationProvider>().loc;

    return onSwitchChanged != null
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: theme.colorScheme.onSurface),
                SizedBox(width: 12.w),

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
                    onChanged: onSwitchChanged,
                    activeThumbColor: theme.colorScheme.primary,
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
                    color: title == loc.deleteData
                        ? Colors.red
                        : theme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 12.w),

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: title == loc.deleteData
                          ? Colors.red
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Spacer(),

                  if (showData != null)
                    Text(
                      showData!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  SizedBox(width: 8.w),

                  if (title != loc.downloadData && title != loc.deleteData)
                    Icon(
                      Icons.chevron_right,
                      size: 18.sp,
                      color: theme.colorScheme.outline,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: child ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ────────── Screen State ──────────
class _SettingScreenState extends State<SettingScreen> {
  int _quickNotesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuickNotesCount();
  }

  Future<void> _loadQuickNotesCount() async {
    final notes = await DatabaseHelper.instance.getQuickNotes();
    if (mounted) {
      setState(() => _quickNotesCount = notes.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = context.watch<LocalizationProvider>();
    final loc = locProvider.loc;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 100.h),
        child: SingleChildScrollView(
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
                        loc.settingsSubtitle,
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

              // ────────── General Settings ──────────
              SettingBackingClasses.settingMenuItem(
                context: context,
                title: loc.generalSettings,
                child: Column(
                  children: [
                    SettingMenuItem(
                      title: loc.editGroup,
                      icon: LucideIcons.folderEdit,
                      showData:
                          '${context.watch<GroupSettingsProvider>().groupSettings.length}',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditGroupSgreen(),
                          ),
                        );
                      },
                    ).build(context),

                    SettingMenuItem(
                      title: loc.darkTheme,
                      icon: LucideIcons.moon,
                      onTap: () {},
                      switchValue: context.watch<ThemeProvider>().isDarkMode,
                      onSwitchChanged: (_) =>
                          context.read<ThemeProvider>().toggleTheme(),
                    ).build(context),

                    SettingMenuItem(
                      title: loc.changeLanguage,
                      icon: LucideIcons.globe,
                      showData: locProvider.language.label,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSettingScreen(),
                          ),
                        );
                      },
                    ).build(context),

                    SettingMenuItem(
                      title: loc.changeCurrency,
                      icon: LucideIcons.circleDollarSign,
                      showData: locProvider.currency.code,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CurrencySettingScreen(),
                          ),
                        );
                      },
                    ).build(context),

                    SettingMenuItem(
                      title: loc.manageNotes,
                      icon: LucideIcons.bookOpen,
                      showData: '$_quickNotesCount',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageNotesScreen(),
                          ),
                        );
                        _loadQuickNotesCount();
                      },
                    ).build(context),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // ────────── Test Scan Settings ──────────
              SettingBackingClasses.settingMenuItem(
                context: context,
                title: loc.scanSettings,
                child: Column(
                  children: [
                    SettingMenuItem(
                      title: loc.scanSettingsTitle,
                      icon: LucideIcons.scan,
                    ).build(context),

                    SettingMenuItem(
                      title: loc.scanNotification,
                      icon: LucideIcons.bell,
                      switchValue: context.watch<ThemeProvider>().isDarkMode,
                      onSwitchChanged: (_) =>
                          context.read<ThemeProvider>().toggleTheme(),
                    ).build(context),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // ────────── Info ──────────
              SettingBackingClasses.settingMenuItem(
                context: context,
                title: loc.additionalSettings,
                child: Column(
                  children: [
                    SettingMenuItem(
                      title: loc.about,
                      icon: LucideIcons.info,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutSgreen(),
                          ),
                        );
                      },
                    ).build(context),

                    SettingMenuItem(
                      title: loc.privacyPolicy,
                      icon: LucideIcons.fileText,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyDialog(),
                          ),
                        );
                      },
                    ).build(context),

                    const Divider(color: Colors.grey),

                    SettingMenuItem(
                      title: loc.downloadData,
                      icon: LucideIcons.download,
                    ).build(context),

                    SettingMenuItem(
                      title: loc.deleteData,
                      icon: LucideIcons.trash,
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(loc.deleteData)));
                      },
                    ).build(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
