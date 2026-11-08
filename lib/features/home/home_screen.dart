import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/core/theme/app_theme.dart';

// ────────── Widgets ──────────
import 'package:bookbank/Widgets/header/header.dart';
import 'package:bookbank/features/home/widgets/dashboard_summary.dart';
import 'package:bookbank/features/home/widgets/cash_box.dart';
import 'package:bookbank/features/home/widgets/group_card.dart';
import 'package:bookbank/features/home/popup/transfer_popup.dart';
import 'package:bookbank/utils/calculations.dart';
import 'package:bookbank/features/home/widgets/menu_items.dart';
import 'package:bookbank/features/menu/editGroup/editGroup_sgreen.dart';

// ────────── Database ──────────
import 'package:bookbank/data/database.dart';
import 'package:bookbank/data/db_helper.dart';
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';

// ────────── Group Data Model ──────────
class GroupData {
  final String groupId;
  final String groupName;
  final int groupCount;
  final double groupAmount;
  final Color groupColor;
  final IconData groupIcon;
  final double percentage;
  final bool savingsGoalEnabled;
  final double savingsGoalAmount;

  GroupData({
    required this.groupId,
    required this.groupName,
    required this.groupCount,
    required this.groupAmount,
    required this.groupColor,
    required this.groupIcon,
    required this.percentage,
    this.savingsGoalEnabled = false,
    this.savingsGoalAmount = 0,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MyData> _transactions = [];
  double _totalBalance = 0;
  double _bankBalance = 0;
  double _cashBalance = 0;

  // Group counts
  int _group1Count = 0;
  int _group2Count = 0;
  int _group3Count = 0;
  int _group4Count = 0;

  // Group amounts
  double _group1Amount = 0;
  double _group2Amount = 0;
  double _group3Amount = 0;
  double _group4Amount = 0;

  // Group incomes
  double _group1Income = 0;
  double _group2Income = 0;
  double _group3Income = 0;
  double _group4Income = 0;
  double _unallocatedAmount = 0;

  // Totals
  double _incomeTotal = 0;
  double _expenseTotal = 0;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  List<FlSpot> _spots = [];

  // Group percentages
  double _group1Percentage = 0;
  double _group2Percentage = 0;
  double _group3Percentage = 0;
  double _group4Percentage = 0;
  double _unallocatedPercentage = 0;

  // Icons
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

  // Helper methods
  IconData _getIconFromCodePoint(int codePoint) {
    return _availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.add,
    );
  }

  GroupData _getGroupData(
    String groupId,
    Color defaultColor,
    List<GroupSettings> groupSettings,
  ) {
    final settings = groupSettings.firstWhere(
      (s) => s.groupId == groupId,
      orElse: () => GroupSettings(
        groupId: groupId,
        groupName: groupId,
        iconCodePoint: Icons.add.codePoint,
        colorValue: defaultColor.toARGB32(),
        savingsGoalEnabled: false,
        savingsGoalAmount: 0,
      ),
    );

    // Get amount based on group ID
    final amount = groupId == 'Group1'
        ? _group1Amount
        : groupId == 'Group2'
        ? _group2Amount
        : groupId == 'Group3'
        ? _group3Amount
        : _group4Amount;

    // Get count based on group ID
    final count = groupId == 'Group1'
        ? _group1Count
        : groupId == 'Group2'
        ? _group2Count
        : groupId == 'Group3'
        ? _group3Count
        : _group4Count;

    // Get percentage based on group ID
    final percentage = groupId == 'Group1'
        ? _group1Percentage
        : groupId == 'Group2'
        ? _group2Percentage
        : groupId == 'Group3'
        ? _group3Percentage
        : _group4Percentage;

    return GroupData(
      groupId: groupId,
      groupName: settings.groupName,
      groupCount: count,
      groupAmount: amount,
      groupColor: Color(settings.colorValue),
      groupIcon: _getIconFromCodePoint(settings.iconCodePoint),
      percentage: percentage,
      savingsGoalEnabled: settings.savingsGoalEnabled,
      savingsGoalAmount: settings.savingsGoalAmount,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from database
  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.getAllData();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _calculateTotals();
    });
  }

  // ────────── Calculate financial totals from transactions ──────────
  void _calculateTotals() {
    final calc = FinancialCalculations(_transactions);

    // Calculate total balance
    _totalBalance = calc.sumAll().toDouble();
    _bankBalance = calc.sumBank().toDouble();
    _cashBalance = calc.sumCash().toDouble();
    _incomeTotal = calc.income().toDouble();
    _expenseTotal = calc.expense().toDouble();
    _monthlyIncome = calc.monthlyIncome();
    _monthlyExpense = calc.monthlyExpense();

    // Calculate group amounts
    _group1Amount = calc.sumGroup('Group1').toDouble();
    _group2Amount = calc.sumGroup('Group2').toDouble();
    _group3Amount = calc.sumGroup('Group3').toDouble();
    _group4Amount = calc.sumGroup('Group4').toDouble();

    // Calculate group incomes
    _group1Income = calc.groupIncome('Group1').toDouble();
    _group2Income = calc.groupIncome('Group2').toDouble();
    _group3Income = calc.groupIncome('Group3').toDouble();
    _group4Income = calc.groupIncome('Group4').toDouble();

    // Calculate group counts
    _group1Count = calc.groupCount('Group1');
    _group2Count = calc.groupCount('Group2');
    _group3Count = calc.groupCount('Group3');
    _group4Count = calc.groupCount('Group4');

    // Calculate unallocated amount
    _unallocatedAmount = calc.unallocatedAmount();

    // Calculate group percentages
    _group1Percentage = calc.calculateGroupPercentage('Group1');
    _group2Percentage = calc.calculateGroupPercentage('Group2');
    _group3Percentage = calc.calculateGroupPercentage('Group3');
    _group4Percentage = calc.calculateGroupPercentage('Group4');
    _unallocatedPercentage = calc.calculateUnallocatedPercentage();

    // Generate monthly spots
    _spots = calc.generateMonthlySpots();
  }

  /// ────────── Handle transfer drop ──────────
  Future<void> _onTransferDrop(GroupDragData source, GroupData target) async {
    if (!mounted) return;

    final result = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (_) => TransferPopup(
        sourceGroupId: source.groupId,
        sourceGroupName: source.groupName,
        sourceGroupColor: source.groupColor,
        sourceGroupIcon: source.groupIcon,
        sourceGroupAmount: source.groupAmount,
        targetGroupId: target.groupId,
        targetGroupName: target.groupName,
        targetGroupColor: target.groupColor,
        targetGroupIcon: target.groupIcon,
      ),
    );

    if (result == null || result <= 0) return;

    final now = DateTime.now().toIso8601String().substring(0, 10);

    await DatabaseHelper.instance.insertData(
      MyData(
        amount: result,
        moneyList: source.groupId,
        moneyType: 'transfer',
        moneyGroup: target.groupId,
        date: now,
        title: 'Transfer: ${source.groupName} → ${target.groupName}',
      ),
    );

    await _loadData();

    // ────────── Show success message ──────────
    if (mounted) {
      final loc = context.read<LocalizationProvider>().loc;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            left: 16.w,
            right: 16.w,
          ),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.background, width: 3),
              ),
            ),
            padding: EdgeInsets.only(left: 8.w),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.background,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    loc.transferSuccess,
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = context.read<LocalizationProvider>().loc;

    return Consumer<GroupSettingsProvider>(
      builder: (context, groupProvider, child) {
        final groupSettings = groupProvider.groupSettings;

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 115.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ────────── Header ──────────
                    Header(),
                    SizedBox(height: 16.h),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ────────── Dashboard Summary ──────────
                            DashboardSummary(
                              totalBalance: _totalBalance,
                              bankBalance: _bankBalance,
                              cashBalance: _cashBalance,
                              incomeTotal: _incomeTotal,
                              expenseTotal: _expenseTotal,
                              monthlyIncome: _monthlyIncome,
                              monthlyExpense: _monthlyExpense,
                              spots: _spots,
                            ),
                            SizedBox(height: 12.h),

                            // ────────── Menu Items ──────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MenuItems(
                                  late: 'Tang in',
                                  icon: LucideIcons.arrowDownToLine,
                                  onPressed: () {},
                                ),

                                MenuItems(
                                  late: 'Tang out',
                                  icon: LucideIcons.arrowUpFromLine,
                                  onPressed: () {},
                                ),

                                MenuItems(
                                  late: 'Transfer',
                                  icon: LucideIcons.repeat,
                                  onPressed: () {},
                                ),

                                MenuItems(
                                  late: 'Scan',
                                  icon: LucideIcons.scan,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            // ────────── Unallocated Summary ──────────
                            Text(
                              loc.cashBox,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            UnallocatedSummary(
                              incomeTotal: _incomeTotal,
                              totalBalance: _totalBalance,
                              unallocatedAmount: _unallocatedAmount,
                              group1Amount: _group1Amount,
                              group2Amount: _group2Amount,
                              group3Amount: _group3Amount,
                              group4Amount: _group4Amount,
                              group1Income: _group1Income,
                              group2Income: _group2Income,
                              group3Income: _group3Income,
                              group4Income: _group4Income,
                              group1Percentage: _group1Percentage,
                              group2Percentage: _group2Percentage,
                              group3Percentage: _group3Percentage,
                              group4Percentage: _group4Percentage,
                              unallocatedPercentage: _unallocatedPercentage,

                              group1Color: _getGroupData(
                                'Group1',
                                theme.colorScheme.primary,
                                groupSettings,
                              ).groupColor,

                              group2Color: _getGroupData(
                                'Group2',
                                theme.colorScheme.secondary,
                                groupSettings,
                              ).groupColor,

                              group3Color: _getGroupData(
                                'Group3',
                                theme.colorScheme.tertiary,
                                groupSettings,
                              ).groupColor,

                              group4Color: _getGroupData(
                                'Group4',
                                theme.colorScheme.error,
                                groupSettings,
                              ).groupColor,

                              // Callback when a group is dropped onto the cash box
                              onTransferDrop: (source) => _onTransferDrop(
                                source,
                                GroupData(
                                  groupId: 'CashBox',
                                  groupName: loc.cashBox,
                                  groupCount: 0,
                                  groupAmount: _unallocatedAmount,
                                  groupColor: Colors.amber,
                                  groupIcon: Icons.savings_rounded,
                                  percentage: _unallocatedPercentage,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // ────────── Group Header ──────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.group,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: theme.colorScheme.outline,
                                  ),
                                ),

                                // Edit Group Button
                                FilledButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          Dialog(child: EditGroupSgreen()),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: theme.colorScheme.outline,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  label: Text(
                                    loc.editGroup,
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  icon: Icon(LucideIcons.edit, size: 16.sp),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ────────── Group1 ──────────
                                Expanded(
                                  child: GroupCard(
                                    groupName: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).groupName,

                                    groupId: 'Group1',
                                    groupCount: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).groupCount,

                                    groupAmount: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).groupAmount,

                                    groupColor: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).groupColor,

                                    groupIcon: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).groupIcon,
                                    transactions: _transactions,

                                    percentage: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).percentage,

                                    savingsGoalEnabled: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).savingsGoalEnabled,

                                    savingsGoalAmount: _getGroupData(
                                      'Group1',
                                      theme.colorScheme.primary,
                                      groupSettings,
                                    ).savingsGoalAmount,

                                    onTransferDrop: (source) => _onTransferDrop(
                                      source,
                                      _getGroupData(
                                        'Group1',
                                        theme.colorScheme.primary,
                                        groupSettings,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                // ────────── Group2 ──────────
                                Expanded(
                                  child: GroupCard(
                                    groupName: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).groupName,

                                    groupId: 'Group2',
                                    groupCount: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).groupCount,

                                    groupAmount: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).groupAmount,

                                    groupColor: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).groupColor,

                                    groupIcon: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).groupIcon,
                                    transactions: _transactions,

                                    percentage: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).percentage,

                                    savingsGoalEnabled: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).savingsGoalEnabled,

                                    savingsGoalAmount: _getGroupData(
                                      'Group2',
                                      theme.colorScheme.secondary,
                                      groupSettings,
                                    ).savingsGoalAmount,

                                    onTransferDrop: (source) => _onTransferDrop(
                                      source,
                                      _getGroupData(
                                        'Group2',
                                        theme.colorScheme.secondary,
                                        groupSettings,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ────────── Group3 ──────────
                                Expanded(
                                  child: GroupCard(
                                    groupName: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).groupName,

                                    groupId: 'Group3',
                                    groupCount: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).groupCount,

                                    groupAmount: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).groupAmount,

                                    groupColor: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).groupColor,

                                    groupIcon: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).groupIcon,
                                    transactions: _transactions,

                                    percentage: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).percentage,

                                    savingsGoalEnabled: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).savingsGoalEnabled,

                                    savingsGoalAmount: _getGroupData(
                                      'Group3',
                                      Colors.purple,
                                      groupSettings,
                                    ).savingsGoalAmount,

                                    onTransferDrop: (source) => _onTransferDrop(
                                      source,
                                      _getGroupData(
                                        'Group3',
                                        Colors.purple,
                                        groupSettings,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                // ────────── Group4 ──────────
                                Expanded(
                                  child: GroupCard(
                                    groupName: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).groupName,

                                    groupId: 'Group4',
                                    groupCount: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).groupCount,

                                    groupAmount: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).groupAmount,

                                    groupColor: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).groupColor,

                                    groupIcon: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).groupIcon,
                                    transactions: _transactions,

                                    percentage: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).percentage,

                                    savingsGoalEnabled: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).savingsGoalEnabled,

                                    savingsGoalAmount: _getGroupData(
                                      'Group4',
                                      Colors.pink,
                                      groupSettings,
                                    ).savingsGoalAmount,

                                    onTransferDrop: (source) => _onTransferDrop(
                                      source,
                                      _getGroupData(
                                        'Group4',
                                        Colors.pink,
                                        groupSettings,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
