// ────────── Packages & Providers ──────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:bookbank/features/onboarding/providers/onboarding_provider.dart';

// ────────── Theme & Localization ──────────
import 'package:bookbank/core/theme/app_theme.dart';
import 'package:bookbank/core/localization/localization_provider.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/menu/editGroup/providers/group_settings_provider.dart';
import 'package:bookbank/features/notebook/providers/note_provider.dart';
import 'package:bookbank/features/onboarding/onboarding_page_1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          // ────────── Add more providers here ──────────
          providers: [
            ChangeNotifierProvider(create: (_) => GroupSettingsProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => NoteProvider()),
            ChangeNotifierProvider(create: (_) => LocalizationProvider()),
            ChangeNotifierProvider(create: (_) => OnboardingProvider()),
          ],

          // ────────── Theme Provider ──────────
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
                localizationsDelegates:
                    material_ui.GlobalMaterialLocalizations.delegates,
                home: const OnboardingWrapper(),

                // ────────── Add responsive breakpoints ──────────
                builder: (context, widget) {
                  return ResponsiveBreakpoints.builder(
                    breakpoints: const [
                      Breakpoint(start: 0, end: 450, name: MOBILE),
                      Breakpoint(start: 451, end: 800, name: TABLET),
                      Breakpoint(start: 801, end: 1920, name: DESKTOP),
                      Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                    ],
                    child: widget!,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
