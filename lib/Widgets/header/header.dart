// ────────── Packages & Providers ──────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ────────── localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/menu/editGroup/editGroup_sgreen.dart';
import 'package:bookbank/features/menu/about/about_sgreen.dart';

// ────────── Header Components ──────────
import 'menu_row.dart';
import 'dark_theme_row.dart';
import 'expandable_menu_item.dart';
import 'sub_menu_item.dart';

// ────────── Header Widget ──────────
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Not yet activated')),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surface,
                      ),
                      icon: Icon(LucideIcons.bell, size: 18.sp),
                    ),

                    // ────────── Popup menu button ──────────
                    PopupMenuButton<String>(
                      icon: Icon(Icons.menu, size: 20.sp),
                      offset: Offset(70.w, 50.h),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          theme.colorScheme.surface,
                        ),
                        side: WidgetStatePropertyAll(
                          BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),

                      // Menu item selection handler
                      onSelected: (String value) {
                        if (value == 'edit_group') {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                Dialog(child: EditGroupSgreen()),
                          );
                        } else if (value == 'about') {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(child: AboutSgreen()),
                          );
                        }
                      },

                      // ────────── Menu items ──────────
                      itemBuilder: (BuildContext context) => [
                        // Edit Category
                        PopupMenuItem<String>(
                          value: 'edit_group',
                          child: MenuRow(
                            icon: Icons.edit,
                            label: loc.editGroup,
                          ),
                        ),

                        // Dark Theme
                        PopupMenuItem<String>(
                          enabled: false, // handled by Switch inside
                          padding: EdgeInsets.zero,
                          child: DarkThemeRow(label: loc.darkTheme),
                        ),

                        // Change Language
                        _buildLanguageItem(context, loc, locProvider, theme),

                        // Change Currency
                        _buildCurrencyItem(context, loc, locProvider, theme),

                        // About
                        PopupMenuItem<String>(
                          value: 'about',
                          child: MenuRow(icon: Icons.info, label: loc.about),
                        ),
                      ],
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

  // ────────── Language submenu popup item ──────────
  PopupMenuItem<String> _buildLanguageItem(
    BuildContext context,
    dynamic loc,
    LocalizationProvider locProvider,
    ThemeData theme,
  ) {
    return PopupMenuItem<String>(
      enabled: false,
      padding: EdgeInsets.zero,
      child: ExpandableMenuItem(
        icon: Icons.language,
        label: loc.changeLanguage,
        badge: '${locProvider.language.flag} ${locProvider.language.label}',
        theme: theme,

        // Language options
        children: AppLanguage.values.map((lang) {
          final isSelected = locProvider.language == lang;
          return SubMenuItem(
            flag: lang.flag,
            label: lang.label,
            isSelected: isSelected,
            theme: theme,
            onTap: () {
              locProvider.setLanguage(lang);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  // ────────── Currency submenu popup item ──────────
  PopupMenuItem<String> _buildCurrencyItem(
    BuildContext context,
    dynamic loc,
    LocalizationProvider locProvider,
    ThemeData theme,
  ) {
    return PopupMenuItem<String>(
      enabled: false,
      padding: EdgeInsets.zero,
      child: ExpandableMenuItem(
        icon: Icons.currency_exchange,
        label: loc.changeCurrency,
        badge: '${locProvider.currency.symbol} ${locProvider.currency.code}',
        theme: theme,
        children: AppCurrency.values.map((curr) {
          final isSelected = locProvider.currency == curr;
          return SubMenuItem(
            flag: curr.symbol,
            label: '${curr.label} (${curr.code})',
            isSelected: isSelected,
            theme: theme,
            onTap: () {
              locProvider.setCurrency(curr);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}
