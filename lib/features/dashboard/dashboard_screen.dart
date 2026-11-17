// ────────── Packages ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';
import 'package:bookbank/features/dashboard/widgets/dashboard.chart.dart';
import 'package:bookbank/features/dashboard/widgets/contribution_graph.dart';

// ────────── Database ──────────
import 'package:bookbank/utils/calculations.dart';
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<MyData> _transactions = [];

  // Total balance
  double _totalBalance = 0;

  final List<IconData> _availableIcons = [
    Icons.shopping_cart_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.flight_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.sports_soccer_rounded,
    Icons.health_and_safety_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.bar_chart_rounded,
    Icons.fastfood_rounded,
    Icons.coffee_rounded,
    Icons.card_giftcard_rounded,
    Icons.celebration_rounded,
    Icons.favorite_rounded,
    Icons.fitness_center_rounded,
    Icons.filter_hdr_rounded,
    Icons.handyman_outlined,
  ];

  // Helper method to get icon from code point
  IconData _getIconFromCodePoint(int codePoint) {
    return _availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.add,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Helper method to load data from database
  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllData();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _calculateData();
    });
  }

  void _calculateData() {
    final calc = FinancialCalculations(_transactions);

    // Calculate total balance
    _totalBalance = calc.sumAll().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Consumer2<GroupSettingsProvider, LocalizationProvider>(
      builder: (context, groupProvider, locProvider, child) {
        final groupSettings = groupProvider.groupSettings;
        final loc = locProvider.loc;

        // All category IDs: configured groups + any category used in transactions
        final categoryIds = <String>{
          ...groupSettings.map((g) => g.groupId),
          ..._transactions
              .where(
                (t) => t.moneyType != 'transfer' && t.moneyGroup.isNotEmpty,
              )
              .map((t) => t.moneyGroup),
        }.toList();

        final categoryIcons = <String, IconData>{};
        final categoryColors = <String, Color>{};
        final categoryNames = <String, String>{};

        for (final id in categoryIds) {
          final settings = groupProvider.getGroupSettings(id);
          categoryIcons[id] = _getIconFromCodePoint(
            settings?.iconCodePoint ?? Icons.add.codePoint,
          );
          final colorValue = settings?.colorValue ?? 0;
          categoryColors[id] = colorValue != 0
              ? Color(colorValue)
              : Colors.blue;
          categoryNames[id] = settings?.groupName ?? id;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 50.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ────────── Header ──────────
                          Row(
                            children: [
                              Icon(
                                LucideIcons.chartNoAxesCombined,
                                size: 24.sp,
                                color: theme.iconTheme.color,
                              ),
                              SizedBox(width: 16.w),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.dashboard,
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontSize: AppSize.l.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    loc.viewStats,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: AppSize.xs.sp,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          // ────────── Total Balance ──────────
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  loc.totalBalance,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: AppSize.xs.sp,
                                  ),
                                ),
                                Text(
                                  locProvider.formatAmount(_totalBalance),
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: AppSize.l.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                    child: Column(
                      children: [
                        // ────────── Chart ──────────
                        DashboardChart(
                          transactions: _transactions,
                          categoryIcons: categoryIcons,
                          categoryColors: categoryColors,
                          categoryNames: categoryNames,
                        ),
                        SizedBox(height: 24.h),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contribution graph',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontSize: AppSize.m.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                ContributionGraph(transactions: _transactions),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
