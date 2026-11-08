// ────────── Package Imports ──────────
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/home/home_screen.dart';
import 'package:bookbank/features/add_transaction/add_transaction_screen.dart';
import 'package:bookbank/features/charts/chart_screen.dart';
import 'package:bookbank/features/records/record_screen.dart';
import 'package:bookbank/features/notebook/noteBook_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// ────────── Stateful Widget ──────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ────────── State Management ──────────
class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  Key _homeKey = UniqueKey();
  Key _recordKey = UniqueKey();

  // Pages to navigate
  List<Widget> get pages => [
    HomeScreen(key: _homeKey),
    RecordScreen(key: _recordKey),
    const AddTransactionScreen(),
    ChartScreen(),
    NoteBookScreen(),
  ];

  // ────────── Build navigation item ──────────
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Color.fromARGB(255, 65, 65, 65), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active indicator
            if (isSelected) ...[
              Container(
                width: double.infinity,
                height: 1.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ],
            SizedBox(height: 12.h),

            // Icons
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.outline,
              size: 18.sp,
            ),
            SizedBox(height: 2.h),

            // label
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.outline,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────── Build the navigation bar ──────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locProvider = Provider.of<LocalizationProvider>(context);
    final loc = locProvider.loc;

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 80.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Black bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceBright,
                    // border: Border(
                    //   top: BorderSide(
                    //     color: theme.scaffoldBackgroundColor,
                    //     width: 1.w,
                    //   ),
                    // ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.r),
                      topRight: Radius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNavItem(0, LucideIcons.house, loc.home),
                      _buildNavItem(1, LucideIcons.layoutList, loc.record),
                      _buildNavItem(
                        3,
                        LucideIcons.chartNoAxesCombined,
                        loc.charts,
                      ),
                      _buildNavItem(4, LucideIcons.notepadText, loc.notes),
                      _buildNavItem(2, LucideIcons.settings, loc.settings),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
