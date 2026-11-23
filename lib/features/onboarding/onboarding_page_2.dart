import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:bookbank/core/localization/localization_provider.dart';
import 'package:bookbank/core/localization/app_localizations.dart';
import 'package:bookbank/features/onboarding/providers/onboarding_provider.dart';
import 'package:bookbank/Widgets/navigation_bar.dart';
import 'package:bookbank/features/setting/widgets/privacy_policy_dialog.dart';

class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  AppCurrency _selectedCurrency = AppCurrency.baht;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onStart() async {
    final locProvider = context.read<LocalizationProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();

    // Save selected currency
    await locProvider.setCurrency(_selectedCurrency);

    // Mark onboarding as done
    await onboardingProvider.completeOnboarding();

    if (!mounted) return;

    // Navigate to main app
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();
    final lang = locProvider.language;
    final loc = locProvider.loc;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image (top half) ───────────────────────────────────
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Image.asset(
                  'lib/core/images/Background_Onbording1.jpeg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(color: Colors.black),
              ),
            ],
          ),

          // ── Top Image Overlay ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.47,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.3, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BookBank',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      _LanguagePill(lang: lang, locProvider: locProvider),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Currency Selection Panel ──────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 0),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.selectCurrency,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Currency Options
                          ...AppCurrency.values.map(
                            (currency) => _CurrencyTile(
                              currency: currency,
                              isSelected: _selectedCurrency == currency,
                              onTap: () =>
                                  setState(() => _selectedCurrency = currency),
                              loc: loc,
                            ),
                          ),

                          SizedBox(height: 28.h),

                          // Start Button
                          _StartButton(label: loc.start, onTap: _onStart),

                          SizedBox(height: 16.h),

                          // Privacy Policy
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => PrivacyPolicyDialog(),
                                );
                              },
                              child: Text(
                                loc.privacyPolicy,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 13.sp,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      Colors.white.withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Currency Tile ────────────────────────────────────────────────────────────

class _CurrencyTile extends StatelessWidget {
  final AppCurrency currency;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations loc;

  const _CurrencyTile({
    required this.currency,
    required this.isSelected,
    required this.onTap,
    required this.loc,
  });

  String get _flag {
    switch (currency) {
      case AppCurrency.baht:
        return '🇹🇭';
      case AppCurrency.dollar:
        return '🇺🇸';
      case AppCurrency.yuan:
        return '🇨🇳';
    }
  }

  String get _displayLabel {
    switch (currency) {
      case AppCurrency.baht:
        return loc.currencyBahtDisplay;
      case AppCurrency.dollar:
        return loc.currencyDollarDisplay;
      case AppCurrency.yuan:
        return loc.currencyYuanDisplay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white38,
                  width: isSelected ? 2 : 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            SizedBox(width: 14.w),

            // Flag
            Text(_flag, style: TextStyle(fontSize: 22.sp)),

            SizedBox(width: 10.w),

            // Currency label
            Text(
              _displayLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Start Button ─────────────────────────────────────────────────────────────

class _StartButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _StartButton({required this.label, required this.onTap});

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Language Pill ────────────────────────────────────────────────────────────

class _LanguagePill extends StatelessWidget {
  final AppLanguage lang;
  final LocalizationProvider locProvider;

  const _LanguagePill({required this.lang, required this.locProvider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: Colors.white, size: 15.sp),
            SizedBox(width: 5.w),
            Text(
              lang.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final loc = locProvider.loc;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.selectLanguage,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ...AppLanguage.values.map(
                (l) => ListTile(
                  leading: Text(l.flag, style: TextStyle(fontSize: 22.sp)),
                  title: Text(
                    l.label,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                  trailing: lang == l
                      ? Icon(Icons.check_circle,
                          color: Colors.white, size: 20.sp)
                      : null,
                  onTap: () {
                    locProvider.setLanguage(l);
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }
}
